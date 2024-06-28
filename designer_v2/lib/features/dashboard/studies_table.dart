import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_item.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyGroup {
  final Study standaloneOrTemplate;
  final List<Study> subStudies;

  StudyGroup(this.standaloneOrTemplate, this.subStudies);

  StudyGroup.standalone(Study standaloneStudy) : this(standaloneStudy, []);

  StudyGroup.template(Template templateStudy, List<Study> subStudies)
      : this(templateStudy, subStudies);
}

enum StudiesTableColumn {
  expand,
  title,
  status,
  participation,
  createdAt,
  enrolled,
  active,
  completed,
  action,
  type
}

class StudiesTableColumnSize {
  final bool collapsed;
  final int? flex;
  final double? width;

  StudiesTableColumnSize._(this.flex, this.width, this.collapsed);
  StudiesTableColumnSize.fixedWidth(double width) : this._(null, width, false);
  StudiesTableColumnSize.flexWidth(int flex) : this._(flex, null, false);
  StudiesTableColumnSize.collapsed() : this._(null, null, true);

  Widget createContainer({required Widget child, double? height}) {
    if (collapsed) {
      return const SizedBox.shrink();
    }
    if (flex != null) {
      return Expanded(flex: flex!, child: child);
    }

    return SizedBox(width: width, height: height, child: child);
  }
}

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studyGroups,
    required this.onSelect,
    required this.onExpand,
    required this.getActions,
    required this.getSubActions,
    required this.emptyWidget,
    required this.pinnedStudies,
    required this.expandedStudies,
    required this.dashboardController,
    this.itemHeight = 60.0,
    this.itemPadding = 10.0,
    this.rowSpacing = 9.0,
    this.columnSpacing = 10.0,
    this.compactWidthThreshold = 1000.0,
    this.superCompactWidthThreshold = 600.0,
    this.compactStatTitleThreshold = 1100.0,
    super.key,
  });

  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final double compactWidthThreshold;
  final double superCompactWidthThreshold;
  final double compactStatTitleThreshold;
  final List<StudyGroup> studyGroups;
  final OnSelectHandler<Study> onSelect;
  final OnSelectHandler<Study> onExpand;
  final ActionsProviderFor<StudyGroup> getActions;
  final ActionsProviderAt<StudyGroup> getSubActions;
  final Widget emptyWidget;
  final Iterable<String> pinnedStudies;
  final Iterable<String> expandedStudies;
  final DashboardController dashboardController;

  @override
  Widget build(BuildContext context) {
    if (studyGroups.isEmpty) {
      return emptyWidget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < compactWidthThreshold;
        final isSuperCompact =
            constraints.maxWidth < superCompactWidthThreshold;
        final isCompactStatTitle =
            constraints.maxWidth < compactStatTitleThreshold;
        // Calculate the minimum stat column width
        final int maxStatTitleLength = isCompactStatTitle
            ? "Completed".length
            : tr.studies_list_header_participants_completed.length;
        final double statsColumnWidth = maxStatTitleLength * 9.9;

        // Calculate the minimum status column width
        int maxStatusLength = "Entwurf".length;
        maxStatusLength =
            max(maxStatusLength, tr.studies_list_header_status.length);
        final double statusColumnWidth = maxStatusLength * 11.5;

        // Calculate the minimum type column width
        int maxTypeLength = "Standalone".length;
        final double typeColumnWidth = maxTypeLength * 8.5;

        // Calculate the minimum participation column width
        final int maxParticipationLength = isCompact
            ? "Invite-only".length
            : tr.participation_invite_who.length;
        maxStatusLength =
            max(maxStatusLength, tr.studies_list_header_participation.length);
        final double participationColumnWidth =
            20 + (maxParticipationLength * 7.5);

        // Set column definitions
        final columnDefinitionsMap = {
          StudiesTableColumn.expand:
              StudiesTableColumnSize.fixedWidth(itemHeight),
          StudiesTableColumn.title: StudiesTableColumnSize.flexWidth(24),
          StudiesTableColumn.type:
              StudiesTableColumnSize.fixedWidth(typeColumnWidth),
          StudiesTableColumn.status:
              StudiesTableColumnSize.fixedWidth(statusColumnWidth),
          StudiesTableColumn.participation:
              StudiesTableColumnSize.fixedWidth(participationColumnWidth),
          StudiesTableColumn.createdAt: isSuperCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.flexWidth(10),
          StudiesTableColumn.enrolled: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.active: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.completed: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.action:
              StudiesTableColumnSize.fixedWidth(itemHeight),
        };
        final columnDefinitions = columnDefinitionsMap.entries.toList();

        final List<Widget> columnRows = [];
        for (final columnDefinition in columnDefinitions) {
          columnRows.add(columnDefinition.value.createContainer(
            child: _buildColumnHeader(columnDefinition.key),
          ));
          if (!columnDefinition.value.collapsed) {
            columnRows.add(SizedBox(width: columnSpacing));
          }
        }

        return Column(
          children: [
            SizedBox(
              height: itemHeight,
              child: Row(
                children: columnRows,
              ),
            ),
            SizedBox(height: rowSpacing),
            ListView.builder(
              itemCount: studyGroups.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = studyGroups[index];
                return StudiesTableItem(
                  studyGroup: item,
                  columnDefinitions: columnDefinitionsMap,
                  actions: getActions(item),
                  getSubActions: getSubActions,
                  isPinned:
                      pinnedStudies.contains(item.standaloneOrTemplate.id),
                  isExpanded:
                      expandedStudies.contains(item.standaloneOrTemplate.id),
                  itemHeight: itemHeight,
                  rowSpacing: rowSpacing,
                  columnSpacing: columnSpacing,
                  onPinnedChanged: (study, pinned) {
                    pinnedStudies.contains(item.standaloneOrTemplate.id)
                        ? dashboardController
                            .pinOffStudy(item.standaloneOrTemplate.id)
                        : dashboardController
                            .pinStudy(item.standaloneOrTemplate.id);
                  },
                  onTapStudy: (study) => onSelect.call(study),
                  onExpandStudy: (study) => onExpand.call(study),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColumnHeader(StudiesTableColumn column) {
    final String title;
    switch (column) {
      case StudiesTableColumn.title:
        title = tr.studies_list_header_title;
      case StudiesTableColumn.type:
        title = tr.studies_list_header_type;
      case StudiesTableColumn.status:
        title = tr.studies_list_header_status;
      case StudiesTableColumn.participation:
        title = tr.studies_list_header_participation;
      case StudiesTableColumn.createdAt:
        title = tr.studies_list_header_created_at;
      case StudiesTableColumn.enrolled:
        title = tr.studies_list_header_participants_enrolled;
      case StudiesTableColumn.active:
        title = tr.studies_list_header_participants_active;
      case StudiesTableColumn.completed:
        title = tr.studies_list_header_participants_completed;
      case StudiesTableColumn.expand:
      case StudiesTableColumn.action:
        title = '';
    }

    final sortAscending = dashboardController.isSortAscending;
    final sortable = !(column == StudiesTableColumn.expand ||
        column == StudiesTableColumn.action);
    final sortingActive = dashboardController.isSortingActiveForColumn(column);

    return StudiesTableColumnHeader(
      title,
      sortable: sortable,
      sortingActive: sortingActive,
      sortAscending: sortAscending,
      onSort: sortable
          ? () {
              dashboardController.setSorting(
                column,
                sortingActive ? !sortAscending : sortAscending,
              );
            }
          : null,
    );
  }
}
