import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyInvitesTable extends StatelessWidget {
  const StudyInvitesTable({
    required this.invites,
    required this.onSelectInvite,
    required this.getActionsForInvite,
    Key? key
  }) : super(key: key);

  final List<StudyInvite> invites;
  final OnSelectHandler<StudyInvite> onSelectInvite;
  final ActionsProviderFor<StudyInvite> getActionsForInvite;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: '#'.hardcoded, columnWidth: FixedColumnWidth(40)),
    StandardTableColumn(
        label: 'Code'.hardcoded, columnWidth: FlexColumnWidth(1.4)),
    StandardTableColumn(
        label: 'Enrolled'.hardcoded, columnWidth: FixedColumnWidth(120)),
    StandardTableColumn(
        label: 'Created at'.hardcoded, columnWidth: FixedColumnWidth(120)),
    StandardTableColumn(
        label: 'Intervention A'.hardcoded, columnWidth: FlexColumnWidth(1.3)),
    StandardTableColumn(
        label: 'Intervention B'.hardcoded, columnWidth: FlexColumnWidth(1.3)),
    StandardTableColumn(label: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyInvite>(
        items: invites,
        columns: columns,
        onSelectItem: onSelectInvite,
        getActionsForItem: getActionsForInvite,
        buildCellsAt: _buildRow,
        cellSpacing: 10.0,
        rowSpacing: 5.0,
        minRowHeight: 30.0,
    );
  }

  List<Widget> _buildRow(BuildContext context, StudyInvite item, int rowIdx) {
    final theme = Theme.of(context);
    final tableTextStylePrimary = theme.textTheme.bodyText1;
    final tableTextSecondaryColor = theme.colorScheme.secondary;
    final tableTextStyleSecondary = tableTextStylePrimary!.copyWith(
        color: tableTextSecondaryColor);
    final tableTextStyleTertiary = tableTextStylePrimary.copyWith(
        color: tableTextSecondaryColor.withOpacity(0.5));

    return [
      Text(rowIdx.toString(), style: tableTextStyleTertiary),
      Text(item.code, style: tableTextStyleSecondary),
      Text('[TODO]', style: tableTextStyleSecondary), // TODO
      Text('[TODO]', style: tableTextStyleSecondary), // TODO
      Text(item.preselectedInterventionIds?[0] ?? '', style: tableTextStyleSecondary), // TODO
      Text(item.preselectedInterventionIds?[1] ?? '', style: tableTextStyleSecondary), // TODO
      ActionPopUpMenuButton(
        actions: getActionsForInvite(item),
        orientation: Axis.horizontal,
        triggerIconColor: tableTextSecondaryColor.withOpacity(0.8),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      ),
    ];
  }
}

/*
class StudyInvitesTable extends StatefulWidget {
  const StudyInvitesTable({
    required this.invites,
    required this.onSelectInvite,
    required this.getActionsForInvite,
    this.cellSpacing = 10.0,
    this.rowSpacing = 9.0,
    this.minRowHeight = 50.0,
    Key? key
  }) : super(key: key);

  final List<StudyInvite> invites;
  final OnSelectInviteHandler onSelectInvite;
  final ActionsProviderFor<StudyInvite> getActionsForInvite;

  final double cellSpacing;
  final double rowSpacing;
  final double minRowHeight;

  @override
  State<StudyInvitesTable> createState() => _StudyInvitesTableState();
}


class _StudyInvitesTableState extends State<StudyInvitesTable> {
  late final List<bool> isRowSelected;

  @override
  void initState() {
    _initSelectionState();
    super.initState();
  }

  @override
  void didUpdateWidget(StudyInvitesTable oldWidget) {
    _initSelectionState();
    super.didUpdateWidget(oldWidget);
  }

  _initSelectionState() {
    isRowSelected = List<bool>.generate(
        widget.invites.length, (int index) => false);
  }

  @override
  Widget build(BuildContext context) {
    print("_StudiesTableState.build");
    final theme = Theme.of(context);

    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text('Number'),
        ),
      ],
      rows: List<DataRow>.generate(
        widget.invites.length,
        (int index) => DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              // All rows will have the same selected color.
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              }
              // Even rows will have a grey color.
              if (index.isEven) {
                return Colors.grey.withOpacity(0.3);
              }
              return null; // Use default value for other states and odd rows.
            }),
          cells: <DataCell>[DataCell(Text('Row $index'))],
          selected: isRowSelected[index],
          onSelectChanged: (bool? value) {
            setState(() {
              isRowSelected[index] = value!;
            });
          },
      ),
    ));
  }
}*/
