import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
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
  final bool sortable;
  final bool filterable;
  final List<String>? filterOptions;

  StudiesTableColumnSize._(
    this.flex,
    this.width,
    this.collapsed,
    this.sortable,
    this.filterable,
    this.filterOptions,
  );
  StudiesTableColumnSize.fixedWidth({
    required double width,
    bool sortable = false,
    bool filterable = false,
    List<String>? filterOptions,
  }) : this._(null, width, false, sortable, filterable, filterOptions);
  StudiesTableColumnSize.flexWidth({
    required int flex,
    bool sortable = false,
    bool filterable = false,
    List<String>? filterOptions,
  }) : this._(flex, null, false, sortable, filterable, filterOptions);
  StudiesTableColumnSize.collapsed()
      : this._(null, null, true, false, false, null);

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
    /*if (studyGroups.isEmpty) {
      return emptyWidget;
    }*/

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
        const int maxTypeLength = "Standalone".length;
        const double typeColumnWidth = maxTypeLength * 8.5;

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
              StudiesTableColumnSize.fixedWidth(width: itemHeight),
          StudiesTableColumn.title: StudiesTableColumnSize.flexWidth(
            flex: 24,
            sortable: true,
          ),
          StudiesTableColumn.type: StudiesTableColumnSize.fixedWidth(
            width: typeColumnWidth,
            sortable: true,
            filterable: true,
            filterOptions: [
              "Standalone",
              "Template",
              "Substudy",
            ],
          ),
          StudiesTableColumn.status: StudiesTableColumnSize.fixedWidth(
            width: statusColumnWidth,
            sortable: true,
            filterable: true,
            filterOptions: [
              "Draft",
              "Live",
              "Closed",
            ],
          ),
          StudiesTableColumn.participation: StudiesTableColumnSize.fixedWidth(
            width: participationColumnWidth,
            sortable: true,
            filterable: true,
            filterOptions: [
              "Everyone",
              "Invite Only",
            ],
          ),
          StudiesTableColumn.createdAt: isSuperCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.flexWidth(flex: 10),
          StudiesTableColumn.enrolled: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(width: statsColumnWidth),
          StudiesTableColumn.active: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(width: statsColumnWidth),
          StudiesTableColumn.completed: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(width: statsColumnWidth),
          StudiesTableColumn.action:
              StudiesTableColumnSize.fixedWidth(width: itemHeight),
        };
        final columnDefinitions = columnDefinitionsMap.entries.toList();

        final List<Widget> columnRows = [];
        for (final columnDefinition in columnDefinitions) {
          columnRows.add(
            columnDefinition.value.createContainer(
              child: _buildColumnHeader(
                  context, columnDefinition.key, columnDefinitionsMap),
            ),
          );
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

  Widget _buildColumnHeader(BuildContext context, StudiesTableColumn column,
      Map<StudiesTableColumn, StudiesTableColumnSize> columnDefinitionsMap) {
    final columnDefinition = columnDefinitionsMap[column]!;
    final title = _getColumnTitle(column);

    final sortAscending = dashboardController.isSortAscending;
    final sortable = !(column == StudiesTableColumn.expand ||
        column == StudiesTableColumn.action);
    final sortingActive = dashboardController.isSortingActiveForColumn(column);

    return StudiesTableColumnHeader(
      title,
      sortable: sortable,
      sortingActive: sortingActive,
      sortAscending: sortAscending,
      filterable: columnDefinition.filterable,
      filterOptions: columnDefinition.filterOptions,
      onSort: sortable
          ? () {
              dashboardController.setSorting(
                column,
                sortingActive ? !sortAscending : sortAscending,
              );
            }
          : null,
      onFilter: columnDefinition.filterable

          /// This function is a filter handler for filtering table columns individually.
          ///
          /// `title`: The key representing the column name.
          /// `query`: The value to filter by. If it's null or empty, the existing filter for column title is removed.
          ///
          ///  Each value in `queryParameters` is checked against the available `StudiesFilter` enum values. If a match is found
          ///  the corresponding `StudiesFilter` is added to the `filters` list.
          ///  The `dashboardController.setStudiesFilter(filters)` method is called to apply the filter settings to the dashboard.
          /// If the column is not filterable, the function returns `null`.
          //TODO: Add support for filtering by multiple values.
          ? (String title, String? query) {
              final Map<String, String> queryParameters =
                  Map.of(Uri.base.queryParameters);

              List<StudiesFilter> filters = [];

              final List<String> titleParts =
                  queryParameters[title]?.split(',') ?? [];

              if (query == null || query.isEmpty) {
                queryParameters.remove(title);
              } else if (titleParts.contains(query)) {
                return;
              } else {
                queryParameters[title] =
                    query.replaceAll(' ', '').toLowerCase();
              }

              for (final filter in queryParameters.values) {
                filters.addAll(
                  StudiesFilter.values.where(
                    (filterEnum) => filterEnum
                        .toString()
                        .split('.')
                        .last
                        .toLowerCase()
                        .contains(filter.toLowerCase()),
                  ),
                );
              }

              dashboardController.setStudiesFilter(filters);

              final newUri = Uri.base.replace(queryParameters: queryParameters);

              html.window.history.pushState(null, '', newUri.toString());
            }
          : null,
    );
  }

  String _getColumnTitle(StudiesTableColumn column) {
    switch (column) {
      case StudiesTableColumn.title:
        return tr.studies_list_header_title;
      case StudiesTableColumn.type:
        return tr.studies_list_header_type;
      case StudiesTableColumn.status:
        return tr.studies_list_header_status;
      case StudiesTableColumn.participation:
        return tr.studies_list_header_participation;
      case StudiesTableColumn.createdAt:
        return tr.studies_list_header_created_at;
      case StudiesTableColumn.enrolled:
        return tr.studies_list_header_participants_enrolled;
      case StudiesTableColumn.active:
        return tr.studies_list_header_participants_active;
      case StudiesTableColumn.completed:
        return tr.studies_list_header_participants_completed;
      case StudiesTableColumn.expand:
      case StudiesTableColumn.action:
        return '';
    }
  }
}
