import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/common_views/sidenav_layout.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SidenavLayout(
        sideDrawerWidget: AppDrawer(title: 'StudyU'.hardcoded),
        mainContentWidget: Scaffold(
          appBar: null, // default app bar not suitable for our layout
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _contentHeader(context, ref),
                          const SizedBox(height: 24.0),
                          // spacing between body elements
                          _studiesTable(context, ref)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }

  Widget _studiesTable(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    const cellSpacing = 16.0;
    const rowSpacing = 6.0;
    const minRowHeight = 50.0;

    // Build table header
    final List<String> headerFields = [
      'Study Title'.hardcoded,
      "Status".hardcoded,
      "Enrollment".hardcoded,
      "Started At".hardcoded,
      "Enrolled Participants".hardcoded,
      "Active Participants".hardcoded,
      "Completed".hardcoded,
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
    // This can be removed later, when we have a working policy
    //final userStudies = state.studies.where((element) => element.isOwner(AuthStore().currentUser) || element.isEditor(AuthStore().currentUser));
    state.visibleStudies.forEach((study) {
      TableRow studyDataRow = TableRow(children: [
        wrapRowContents(Text(study.title ?? '[Missing Study.title]')),
        wrapRowContents(SelectableText(study.status.value)),
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
                onSelected: (ModelAction<StudyActionType> action) {
                  action.onExecute();
                },
                itemBuilder: (BuildContext context) {
                  return controller.getAvailableActionsFor(study).map((action) {
                    return PopupMenuItem(
                      value: action,
                      child: action.isDestructive
                          ? Text(action.label,
                              style: const TextStyle(color: Colors.red))
                          : Text(action.label),
                    );
                  }).toList();
                }),
            hasInkwell: false),
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

  Widget _contentHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SelectableText("My Studies".hardcoded,
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
          label: Text("New study".hardcoded),
          onPressed: () {
            // Open new study page
            context.goNamed(
                RouterPage.study.id,
                params: {'studyId': Config.newStudyId}
            );
          },
        )
      ],
    );
  }
}
