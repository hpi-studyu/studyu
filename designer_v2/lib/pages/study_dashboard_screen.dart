import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/model.dart';
import '../domain/study.dart';
import '../services/auth_store.dart';
import '../services/study_provider.dart';
import '../views/navigation_drawer.dart';
import '../views/sidenav_layout.dart';

// TODOS
// - Implement: Load studies from Supabase (copy from main repo)
// - After: Architecture refactor + migrate to main repo + integrate

class StudyDashboardScreen extends ConsumerStatefulWidget {
  const StudyDashboardScreen({Key? key}) : super(key: key);

  @override
  StudyDashboardScreenState createState() => StudyDashboardScreenState();
}

class StudyDashboardScreenState extends ConsumerState<StudyDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SidenavLayout(
        sideDrawerWidget: const NavigationDrawer(title: 'StudyU'),
        mainContentWidget: Scaffold(
          appBar: null, // default app bar not suitable for our layout
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentHeader(context),
                const SizedBox(height: 24.0), // spacing between body elements
                _buildStudiesTable(context)
              ],
            ),
          ),
        ));
  }

  Widget _buildStudiesTable(BuildContext context) {
    final theme = Theme.of(context);
    final StudyProvider studyProvider = StudyProvider.shared;

    const cellSpacing = 16.0;
    const rowSpacing = 6.0;
    const minRowHeight = 50.0;

    // Build table header
    const List<String> headerFields = [
      "Study Title",
      "Status",
      "Enrollment",
      "Started At",
      "Enrolled Participants",
      "Active Participants",
      "Completed",
      ""
    ];
    final headerRow = TableRow(
        children: headerFields
            .map((fieldName) => Padding(
                  padding: const EdgeInsets.all(cellSpacing),
                  child: SelectableText(fieldName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList());

    // TODO: Switch to data table for built-in Inkwell
    Widget wrapRowContents(Widget widget, {hasInkwell = true}) {
      Widget innerContent = Padding(
          padding: const EdgeInsets.all(cellSpacing),
          child: SizedBox(height: minRowHeight, child: Align(child: widget)));

      return Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.05),
          ),
          child: (!hasInkwell)
              ? innerContent
              : TableRowInkWell(onTap: () {}, child: innerContent));
    }

    // Build row for each study
    final List<TableRow> rows = [];
    studyProvider.studies.forEach((study) {
      final studyMenuItems = study.availableActions().map((action) {
        return PopupMenuItem(
          value: action,
          child: action.isDestructive
              ? Text(action.label, style: TextStyle(color: Colors.red))
              : Text(action.label),
        );
      }).toList();

      TableRow studyDataRow = TableRow(children: [
        wrapRowContents(Text(study.title)),
        wrapRowContents(SelectableText(study.status)),
        wrapRowContents(SelectableText(study.enrollmentTypeValue)),
        wrapRowContents(SelectableText(study.startDate ?? "")),
        wrapRowContents(SelectableText(study.countEnrolled.toString()),
            hasInkwell: false),
        wrapRowContents(SelectableText(study.countActive.toString()),
            hasInkwell: false),
        wrapRowContents(SelectableText(study.countCompleted.toString()),
            hasInkwell: false),
        wrapRowContents(
            PopupMenuButton(
                elevation: 5,
                onSelected: (ModelAction<StudyActionType> action) {
                  action.onExecute();
                },
                itemBuilder: (BuildContext context) => studyMenuItems),
            hasInkwell: false
            /*
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => print(study.title),
                  hoverColor: theme.colorScheme.primaryContainer,
                  splashRadius: 24.0,)

               */
            ),
      ]);

      TableRow rowSpacer = const TableRow(children: [
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
    });

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
            children: [headerRow, ...rows]));
  }

  Widget _buildContentHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SelectableText(
            "My Studies ${ref.read(authServiceProvider.notifier).currentUser?.email}",
            style: theme.textTheme.headline5
                ?.copyWith(fontWeight: FontWeight.bold)),
        Container(width: 32.0),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            // Foreground color
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            // Background color
            primary: Theme.of(context).colorScheme.primary,
          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
          icon: const Icon(Icons.add),
          label: const Text("New study"),
          onPressed: () {
            if (kDebugMode) {
              print("new study");
            }
          },
        )
      ],
    );
  }
}
