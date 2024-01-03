import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_item.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum StudiesTableColumn { pin, title, status, participation, createdAt, enrolled, active, completed, action }

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

    return SizedBox(width: width!, height: height, child: child);
  }
}

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studies,
    required this.onSelect,
    required this.getActions,
    required this.emptyWidget,
    required this.pinnedStudies,
    required this.dashboardController,
    this.itemHeight = 60.0,
    this.itemPadding = 10.0,
    this.rowSpacing = 9.0,
    this.columnSpacing = 10.0,
    this.compactWidthThreshold = 800.0,
    super.key,
  });

  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final double compactWidthThreshold;
  final List<Study> studies;
  final OnSelectHandler<Study> onSelect;
  final ActionsProviderFor<Study> getActions;
  final Widget emptyWidget;
  final Iterable<String> pinnedStudies;
  final DashboardController dashboardController;

  @override
  Widget build(BuildContext context) {
    if (studies.isEmpty) {
      return emptyWidget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < compactWidthThreshold;
        debugPrint('isCompact: ${constraints.maxWidth}');
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
        int maxStatusLength = "Entwurf".length;
        maxStatusLength = max(maxStatusLength, tr.studies_list_header_status.length);
        final double statusColumnWidth = maxStatusLength * 11.5;

        // Calculate the minimum participation column width
        const int maxParticipationLength = "Invite-only".length;
        maxStatusLength = max(maxStatusLength, tr.studies_list_header_participation.length);
        const double participationColumnWidth = 20 + (maxParticipationLength * 7.5);

        // Set column definitions
        final columnDefinitionsMap = {
          StudiesTableColumn.pin: StudiesTableColumnSize.fixedWidth(itemHeight),
          StudiesTableColumn.title: StudiesTableColumnSize.flexWidth(24),
          StudiesTableColumn.status: StudiesTableColumnSize.fixedWidth(statusColumnWidth),
          StudiesTableColumn.participation: StudiesTableColumnSize.fixedWidth(participationColumnWidth),
          StudiesTableColumn.createdAt: StudiesTableColumnSize.flexWidth(10),
          StudiesTableColumn.enrolled:
              isCompact ? StudiesTableColumnSize.collapsed() : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.active:
              isCompact ? StudiesTableColumnSize.collapsed() : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.completed:
              isCompact ? StudiesTableColumnSize.collapsed() : StudiesTableColumnSize.fixedWidth(statsColumnWidth),
          StudiesTableColumn.action: StudiesTableColumnSize.fixedWidth(itemHeight)
        };
        final columnDefinitions = columnDefinitionsMap.entries.toList();

        return Column(
          children: [
            SizedBox(
              height: itemHeight,
              child: Row(
                children: [
                  columnDefinitions[0].value.createContainer(child: _buildColumnHeader(columnDefinitions[0].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[1].value.createContainer(child: _buildColumnHeader(columnDefinitions[1].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[2].value.createContainer(child: _buildColumnHeader(columnDefinitions[2].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[3].value.createContainer(child: _buildColumnHeader(columnDefinitions[3].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[4].value.createContainer(child: _buildColumnHeader(columnDefinitions[4].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[5].value.createContainer(child: _buildColumnHeader(columnDefinitions[5].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[6].value.createContainer(child: _buildColumnHeader(columnDefinitions[6].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[7].value.createContainer(child: _buildColumnHeader(columnDefinitions[7].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                  columnDefinitions[8].value.createContainer(child: _buildColumnHeader(columnDefinitions[8].key)),
                  SizedBox(
                    width: columnSpacing,
                  ),
                ],
              ),
            ),
            SizedBox(height: rowSpacing),
            ListView.builder(
              itemCount: studies.length,
              itemExtent: (2 * itemPadding) + itemHeight + rowSpacing,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = studies[index];
                return StudiesTableItem(
                  study: item,
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
                  onTap: (study) => onSelect.call(study),
                );
              },
            )
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
              dashboardController.setSorting(column, sortingActive ? !sortAscending : sortAscending);
            }
          : null,
    );
  }
}
