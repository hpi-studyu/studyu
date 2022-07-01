import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef OnSelectStudyHandler = void Function(Study study);
typedef StudyActionsProvider = List<ModelAction> Function(Study study);

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studies,
    required this.onSelectStudy,
    required this.getActionsForStudy,
    this.cellSpacing = 16.0,
    this.rowSpacing = 6.0,
    this.minRowHeight = 50.0,
    Key? key
  }) : super(key: key);

  final List<Study> studies;
  final OnSelectStudyHandler onSelectStudy;
  final StudyActionsProvider getActionsForStudy;

  final double cellSpacing;
  final double rowSpacing;
  final double minRowHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
        color: Colors.transparent,
        child: Table(
            columnWidths: const {
              0: MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(2.5)),
              1: FlexColumnWidth(1.3),
              2: FlexColumnWidth(1.3),
              3: FlexColumnWidth(1.3),
              4: FlexColumnWidth(1.1),
              5: FlexColumnWidth(1.1),
              6: FlexColumnWidth(1.1),
              7: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _tableHeaderRow(),
              ..._tableDataRows(theme)
            ]));
  }

  List<TableRow> _tableDataRows(ThemeData theme) {
    final List<TableRow> rows = [];

    for (final study in studies) {
      // TODO: Switch to data table for built-in Inkwell
      Widget wrapRowContents(Widget widget, {hasInkwell = true}) {
        Widget innerContent = Padding(
            padding: EdgeInsets.all(cellSpacing),
            child: SizedBox(height: minRowHeight, child: Align(child: widget))
        );
        return Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.35),
            ),
            child: (!hasInkwell) ? innerContent : TableRowInkWell(
                onTap: () => onSelectStudy(study),
                child: innerContent
            )
        );
      }

      TableRow studyDataRow = TableRow(children: [
        wrapRowContents(Text(study.title ?? '[Missing Study.title]')),
        wrapRowContents(SelectableText(study.status.string)),
        wrapRowContents(SelectableText(study.participation.value)),
        // TODO: resolve missing createdAt
        //wrapRowContents(SelectableText(study.createdAt.toString())),
        wrapRowContents(SelectableText("")),
        wrapRowContents(SelectableText(study.participantCount.toString()),
            hasInkwell: false),
        wrapRowContents(SelectableText(study.activeSubjectCount.toString()),
            hasInkwell: false),
        wrapRowContents(SelectableText(study.endedCount.toString()),
            hasInkwell: false),
        wrapRowContents(
            PopupMenuButton(
                elevation: 5,
                onSelected: (ModelAction action) {
                  action.onExecute();
                },
                itemBuilder: (BuildContext context) {
                  return getActionsForStudy(study).map((action) {
                    return PopupMenuItem(
                      value: action,
                      child: action.isDestructive
                          ? Text(action.label,
                          style: const TextStyle(color: Colors.red))
                          : Text(action.label),
                    );
                  }).toList();
                }
            ),
            hasInkwell: false),
      ]);

      TableRow rowSpacer = TableRow(children: [
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
        SizedBox(height: rowSpacing),
      ]);

      rows.add(studyDataRow);
      rows.add(rowSpacer);
    }

    return rows;
  }

  TableRow _tableHeaderRow() {
    final List<String> columns = [
      'Study Title'.hardcoded,
      "Status".hardcoded,
      "Enrollment".hardcoded,
      "Started At".hardcoded,
      "Enrolled Participants".hardcoded,
      "Active Participants".hardcoded,
      "Completed".hardcoded,
      ""
    ];

    return TableRow(
        children: columns.map(
            (fieldName) => Padding(
                padding: EdgeInsets.all(cellSpacing),
                child: SelectableText(fieldName,
                    style: const TextStyle(fontWeight: FontWeight.bold))
            )
        ).toList()
    );
  }
}
