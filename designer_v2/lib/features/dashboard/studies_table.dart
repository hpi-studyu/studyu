import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_item.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyGroup {
  final bool isSingleStudy;
  final String id;
  final String? title;
  final List<Study> studies;
  Study get first => studies.first;
  DateTime? get createdAt => studies
      .where((s) => s.createdAt != null)
      .sortedBy((s) => s.createdAt!)
      .firstOrNull
      ?.createdAt;
  int get participantCount => studies.map((s) => s.participantCount).sum;
  int get activeSubjectCount => studies.map((s) => s.activeSubjectCount).sum;
  int get endedCount => studies.map((s) => s.endedCount).sum;

  StudyGroup(this.studies, this.title, this.id, {this.isSingleStudy = false}) {
    if (studies.isEmpty) {
      throw ArgumentError("The studies list should not be empty.");
    }
  }
  StudyGroup.single(Study study) : this([study], study.title, study.id, isSingleStudy: true);
}

enum StudiesTableColumn {
  pin,
  title,
  status,
  participation,
  createdAt,
  enrolled,
  active,
  completed,
  action
}

class StudiesTableColumnSize {
  final int? flex;
  final double? width;

  StudiesTableColumnSize._(this.flex, this.width);
  StudiesTableColumnSize.fixedWidth(double width) : this._(null, width);
  StudiesTableColumnSize.flexWidth(int flex) : this._(flex, null);

  Widget createContainer({required Widget child, double? height}) {
    if (flex != null) {
      return Expanded(flex: flex!, child: child);
    }

    return SizedBox(width: width!, height: height, child: child);
  }
}

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studyGroups,
    required this.onSelect,
    required this.getActions,
    required this.emptyWidget,
    required this.pinnedStudies,
    required this.dashboardController,
    this.itemHeight = 60.0,
    this.itemPadding = 10.0,
    this.rowSpacing = 9.0,
    this.columnSpacing = 10.0,
    super.key,
  });

  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final List<StudyGroup> studyGroups;
  final OnSelectHandler<Study> onSelect;
  final ActionsProviderFor<StudyGroup> getActions;
  final Widget emptyWidget;
  final Iterable<String> pinnedStudies;
  final DashboardController dashboardController;

  @override
  Widget build(BuildContext context) {
    if (studyGroups.isEmpty) {
      return emptyWidget;
    }

    // Calculate the minimum stat column width
    List<String> statTitles = [
      tr.studies_list_header_participants_enrolled,
      tr.studies_list_header_participants_active,
      tr.studies_list_header_participants_completed,
    ];
    final int maxStatTitleLength =
        statTitles.fold(0, (max, element) => max > element.length ? max : element.length);
    final double statsColumnWidth = maxStatTitleLength * 9.5;

    // Calculate the minimum status column width
    final statuses = HashSet<StudyStatus>();
    for (final studyGroup in studyGroups) {
      for (final study in studyGroup.studies) {
        statuses.add(study.status);
      }
    }
    int maxStatusLength = statuses.fold(
        0, (max, element) => max > element.string.length ? max : element.string.length);
    maxStatusLength = max(maxStatusLength, tr.studies_list_header_status.length);
    final double statusColumnWidth = maxStatusLength * 11.5;

    // Calculate the minimum participation column width
    final participations = HashSet<Participation>();
    for (final studyGroup in studyGroups) {
      for (final study in studyGroup.studies) {
        participations.add(study.participation);
      }
    }
    int maxParticipationLength = participations.fold(
        0, (max, element) => max > element.whoShort.length ? max : element.whoShort.length);
    maxStatusLength = max(maxStatusLength, tr.studies_list_header_participation.length);
    final double participationColumnWidth = 20 + (maxParticipationLength * 7.5);

    // Set column definitions
    final columnDefinitionsMap = {
      StudiesTableColumn.pin: StudiesTableColumnSize.fixedWidth(40),
      StudiesTableColumn.title: StudiesTableColumnSize.flexWidth(24),
      StudiesTableColumn.status: StudiesTableColumnSize.fixedWidth(statusColumnWidth),
      StudiesTableColumn.participation: StudiesTableColumnSize.fixedWidth(participationColumnWidth),
      StudiesTableColumn.createdAt: StudiesTableColumnSize.flexWidth(10),
      StudiesTableColumn.enrolled: StudiesTableColumnSize.fixedWidth(statsColumnWidth),
      StudiesTableColumn.active: StudiesTableColumnSize.fixedWidth(statsColumnWidth),
      StudiesTableColumn.completed: StudiesTableColumnSize.fixedWidth(statsColumnWidth),
      StudiesTableColumn.action: StudiesTableColumnSize.fixedWidth(itemHeight)
    };
    final columnDefinitions = columnDefinitionsMap.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: itemHeight,
          child: Row(
            children: [
              columnDefinitions[0]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[0].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[1]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[1].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[2]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[2].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[3]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[3].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[4]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[4].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[5]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[5].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[6]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[6].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[7]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[7].key)),
              SizedBox(
                width: columnSpacing,
              ),
              columnDefinitions[8]
                  .value
                  .createContainer(child: _buildColumnHeader(columnDefinitions[8].key)),
              SizedBox(
                width: columnSpacing,
              ),
            ],
          ),
        ),
        SizedBox(height: rowSpacing),
        ListView.builder(
          itemCount: studyGroups.length,
          //itemExtent: (2 * itemPadding) + itemHeight + rowSpacing,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = studyGroups[index];
            return StudiesTableItem(
              studyGroup: item,
              columnSizes: columnDefinitionsMap.values.toList(),
              actions: getActions(item),
              isPinned: pinnedStudies.contains(item.id),
              itemHeight: itemHeight,
              rowSpacing: rowSpacing,
              columnSpacing: columnSpacing,
              onPinnedChanged: (study, pinned) {
                pinnedStudies.contains(item.id)
                    ? dashboardController.pinOffStudy(item.id)
                    : dashboardController.pinStudy(item.id);
              },
              onTapStudy: (study) => onSelect.call(study),
            );
          },
        )
      ],
    );
  }

  Widget _buildColumnHeader(StudiesTableColumn column) {
    final String title;
    switch (column) {
      case StudiesTableColumn.title:
        title = tr.studies_list_header_title;
        break;
      case StudiesTableColumn.status:
        title = tr.studies_list_header_status;
        break;
      case StudiesTableColumn.participation:
        title = tr.studies_list_header_participation;
        break;
      case StudiesTableColumn.createdAt:
        title = tr.studies_list_header_created_at;
        break;
      case StudiesTableColumn.enrolled:
        title = tr.studies_list_header_participants_enrolled;
        break;
      case StudiesTableColumn.active:
        title = tr.studies_list_header_participants_active;
        break;
      case StudiesTableColumn.completed:
        title = tr.studies_list_header_participants_completed;
        break;
      case StudiesTableColumn.pin:
      case StudiesTableColumn.action:
        title = '';
        break;
    }

    final sortAscending = dashboardController.isSortAscending;
    final sortable = !(column == StudiesTableColumn.pin || column == StudiesTableColumn.action);
    final sortingActive = dashboardController.isSortingActiveForColumn(column);

    return StudiesTableColumnHeader(
      title,
      sortable: sortable,
      sortingActive: sortingActive,
      sortAscending: sortAscending,
      onSort: sortable
          ? () {
              dashboardController.setSorting(
                  column, sortingActive ? !sortAscending : sortAscending);
            }
          : null,
    );
  }
}
