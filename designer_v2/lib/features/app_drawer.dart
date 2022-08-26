import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/icons.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';

typedef OnEntrySelectedCallback = void Function(BuildContext, WidgetRef);

class DrawerEntry {
  const DrawerEntry({
    required this.title,
    this.icon,
    this.onSelected,
    this.helpText,
  });
  final String title;
  final IconData? icon;
  final String? helpText;
  final OnEntrySelectedCallback? onSelected;

  void onClick(BuildContext context, WidgetRef ref) {
    if (onSelected != null) {
      onSelected!(context, ref);
    }
  }
}

class GoRouterDrawerEntry extends DrawerEntry {
  const GoRouterDrawerEntry({
    required super.title,
    super.icon,
    super.helpText,
    required this.intent,
  });
  final RoutingIntent intent;

  @override
  onClick(BuildContext context, WidgetRef ref) {
    super.onClick(context, ref);
    ref.read(routerProvider).dispatch(intent);
  }
}

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({
    required this.title,
    this.width = 250,
    this.leftPaddingEntries = 28.0,
    this.logoPaddingVertical = 24.0,
    this.logoPaddingHorizontal = 48.0,
    this.logoMaxHeight = 30,
    this.logoSectionMinHeight = 110,
    this.logoSectionMaxHeight = double.infinity,
    Key? key,
  }) : super(key: key);

  final String title;
  final int width;
  final double leftPaddingEntries;
  final double logoPaddingVertical;
  final double logoPaddingHorizontal;
  final double logoMaxHeight;
  final double logoSectionMinHeight;
  final double logoSectionMaxHeight;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  /// List of sections with their corresponding menu entries
  final List<List<GoRouterDrawerEntry>> topEntries = [
    [
      GoRouterDrawerEntry(
        title: tr.my_studies,
        icon: Icons.folder_copy_rounded,
        intent: RoutingIntents.studies,
      ),
      GoRouterDrawerEntry(
        title: 'Shared With Me'.hardcoded,
        icon: Icons.folder_shared_rounded,
        intent: RoutingIntents.studiesShared,
      ),
    ],
    [
      GoRouterDrawerEntry(
        title: 'Study Registry'.hardcoded,
        icon: Icons.public,
        intent: RoutingIntents.publicRegistry,
        helpText: "The study registry is a public collection of studies "
                "conducted on the StudyU \nplatform. In the spirit of "
                "open science, it fosters collaboration & transparency "
                "\namong all researchers & clinicians on the platform."
            .hardcoded,
      ),
    ]
  ];

  /// List of sections with their corresponding menu entries
  final List<List<DrawerEntry>> bottomEntries = [
    [
      DrawerEntry(
        title: 'Settings'.hardcoded,
        icon: Icons.settings_rounded,
      ),
      DrawerEntry(
        title: 'Sign out'.hardcoded,
        icon: Icons.logout_rounded,
        onSelected: (context, ref) {
          ref.read(authControllerProvider.notifier).signOut();
        },
      ),
    ],
  ];

  List<DrawerEntry> get allEntries =>
      [...topEntries, ...bottomEntries].expand((e) => e).toList();

  /// Index of the currently selected [[NavigationGoRouterEntry]]
  /// Defaults to -1 if none of the entries is currently selected
  int _selectedIdx = -1;

  @override
  void didUpdateWidget(AppDrawer oldWidget) {
    // Changing routes will rebuilt the widget if it's below the Navigator
    // (which should almost always be the case for a drawer)
    // That means we can listen for route changes here
    _updateSelectedRoute();
    super.didUpdateWidget(oldWidget);
  }

  void _updateSelectedRoute() {
    final entryIdx = _getCurrentRouteIndex();
    setSelectedIdx(entryIdx);
  }

  int _getCurrentRouteIndex() {
    final currentRouteSettings = readCurrentRouteSettingsFrom(context);
    final idx = allEntries.indexWhere((e) {
      if (e is! GoRouterDrawerEntry) {
        return false;
      }
      return e.intent.matches(currentRouteSettings);
    });
    return idx;
  }

  void setSelectedIdx(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(splashColor: Colors.transparent), // disable splash
      child: Drawer(
        width: widget.width.toDouble(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ListTileTheme(
                selectedColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  shrinkWrap: false,
                  children: [
                    _buildLogo(context),
                    ..._buildTopMenuItems(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(children: _buildBottomMenuItems(context)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
        constraints: BoxConstraints(minHeight: widget.logoSectionMinHeight, maxHeight: widget.logoSectionMaxHeight),
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.logoMaxHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.logoPaddingHorizontal, vertical: widget.logoPaddingVertical),
            child: GestureDetector(
              onTap: () => ref
                  .read(routerProvider)
                  .dispatch(RoutingIntents.root),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  backgroundBlendMode: BlendMode.color,
                ),
                child: Image.asset(
                  'assets/images/icon_wide.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
    );

    return Padding(
      padding: EdgeInsets.all(widget.leftPaddingEntries),
      child: SelectableText(
        widget.title,
        style: textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  _buildSections(List<List<DrawerEntry>> sections) {
    final List<Widget> widgets = [];
    for (final section in sections) {
      for (final entry in section) {
        widgets.add(_entryToListTile(entry));
      }
      // Add section divider
      widgets.add(const SizedBox(height: 8));
      widgets.add(const Divider(height: 1));
      widgets.add(const SizedBox(height: 8));
    }
    // Slice off the last section divider
    return widgets.sublist(0, widgets.length - 3);
  }

  List<Widget> _buildTopMenuItems(BuildContext context) {
    return _buildSections(topEntries);
  }

  List<Widget> _buildBottomMenuItems(BuildContext context) {
    return _buildSections(bottomEntries);
  }

  ListTile _entryToListTile(DrawerEntry entry) {
    final theme = Theme.of(context);
    final entryIdx = allEntries.indexOf(entry);
    final isSelected = entryIdx == _selectedIdx;

    return ListTile(
      trailing: (entry.helpText != null)
          ? IntrinsicWidth(
              child: Row(
                children: [
                  HelpIcon(tooltipText: entry.helpText),
                  const SizedBox(width: 24.0),
                ],
              ),
            )
          : null,
      leading: Icon(
        entry.icon,
        size: theme.iconTheme.size! * 1.2,
        color: (isSelected) ? null : theme.iconTheme.color!.faded(0.75),
      ),
      //hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      title: Text(
        entry.title,
        style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      contentPadding: EdgeInsets.only(left: widget.leftPaddingEntries),
      selected: isSelected,
      onTap: () => entry.onClick(context, ref),
    );
  }
}