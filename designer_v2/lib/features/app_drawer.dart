import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';


class DrawerEntry {
  const DrawerEntry(this.title);
  final String title;

  void onClick(BuildContext context) {
    // subclass responsibility
  }
}

class GoRouterDrawerEntry extends DrawerEntry {
  const GoRouterDrawerEntry(title, this.routerPage) : super(title);
  final RouterPage routerPage;

  @override
  onClick(BuildContext context) {
    context.goNamed(routerPage.id);
  }
}


class AppDrawer extends ConsumerStatefulWidget {
  final String title;
  final int width;

  AppDrawer({required this.title, this.width = 260, Key? key})
      : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  /// List of sections with their corresponding menu entries
  final List<List<GoRouterDrawerEntry>> entries = [
    [
      GoRouterDrawerEntry('My Studies'.hardcoded, RouterPage.dashboard),
      GoRouterDrawerEntry('Shared With Me'.hardcoded, RouterPage.dashboardShared),
    ],
    [
      GoRouterDrawerEntry('Study Registry'.hardcoded, RouterPage.registry),
    ]
  ];

  /// Index of the currently selected [[NavigationGoRouterEntry]]
  /// Defaults to -1 if none of the entries is currently selected
  int _selectedIdx = -1;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = ref.read(routerProvider);
    _router.addListener(_updateSelectedRoute);
    _updateSelectedRoute();
  }

  void _updateSelectedRoute() {
    final entryIdx = _getCurrentRouteIndex();
    setSelectedIdx(entryIdx);
  }

  int _getCurrentRouteIndex() {
    final flattenedEntries = entries.expand((e) => e).toList();
    final idx = flattenedEntries.indexWhere(
            (e) => _router.namedLocation(e.routerPage.id) == _router.currentPath);
    return idx;
  }

  void setSelectedIdx(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  @override
  void dispose() {
    _router.removeListener(_updateSelectedRoute);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
        width: widget.width.toDouble(),
        backgroundColor: theme.colorScheme.surface,
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
                      _buildLogoTile(context),
                      ..._buildEntryTiles(context),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                    children: _buildBottomMenuItems(context)
                ),
              )
            ]
        )
    );
  }

  Widget _buildLogoTile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SelectableText(
        widget.title,
        style: textTheme.headline5
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildEntryTiles(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> widgets = [];
    var currentIdx = 0;
    for (final section in entries) {
      for (final entry in section) {
        final isSelected = currentIdx == _selectedIdx;
        widgets.add(
          ListTile(
            hoverColor:
            theme.colorScheme.primaryContainer.withOpacity(0.4),
            title: Text(entry.title,
                style: isSelected
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null),
            contentPadding: const EdgeInsets.only(left: 32.0),
            selected: isSelected,
            onTap: () => entry.onClick(context),
          ),
        );
        currentIdx += 1;
      }
      // Add section divider
      widgets.add(const SizedBox(height: 8));
      widgets.add(const Divider(height: 1));
      widgets.add(const SizedBox(height: 8));
    }
    // Slice off the last section divider
    return widgets.sublist(0, widgets.length-3);
  }

  List<Widget> _buildBottomMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final authController = ref.watch(authControllerProvider.notifier);

    return [
      ListTile(
        hoverColor:
        theme.colorScheme.primaryContainer.withOpacity(0.4),
        title: Text('Change language'.hardcoded),
        contentPadding: const EdgeInsets.only(left: 48.0),
        // TODO: open settings page/modal
      ),
      ListTile(
        hoverColor:
        theme.colorScheme.primaryContainer.withOpacity(0.4),
        title: Text('Sign out'.hardcoded),
        contentPadding: const  EdgeInsets.only(left: 48.0),
        onTap: authController.signOut,
      ),
    ];
  }


}
