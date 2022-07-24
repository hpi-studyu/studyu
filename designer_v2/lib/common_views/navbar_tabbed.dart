import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class NavbarTab {
  NavbarTab({
    required this.title,
    required this.intent,
    required this.index
  });

  /// The text displayed as the tab's title
  final String title; // TODO: use localization key here

  /// The route to navigate to when switching to the tab
  final RoutingIntent intent;

  final int index;
}

class TabbedNavbar extends ConsumerStatefulWidget {
  const TabbedNavbar({
    required this.tabs,
    this.selectedTab,
    this.indicator,
    Key? key
  }) : super(key: key);

  final List<NavbarTab> tabs;
  final NavbarTab? selectedTab;
  final BoxDecoration? indicator;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabbedNavbarState();
}

class _TabbedNavbarState extends ConsumerState<TabbedNavbar>
    with TickerProviderStateMixin {

  /// A [TabController] that has its index synced to the currently selected
  /// tab provided by the widget. The widget's parameter may be injected e.g.
  /// via a router
  late final TabController _tabController;

  int get selectedTabIndex => widget.selectedTab?.index ?? widget.tabs[0].index;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: widget.tabs.length,
        vsync: this);
    _tabController.index = selectedTabIndex;
  }

  @override
  void didUpdateWidget(TabbedNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync up the tab controller when a new widget is created
    // (e.g. by navigating to a different page)
    _tabController.animateTo(selectedTabIndex);
  }

  void _onSelectTab(int tabIndex) {
    // Navigate to the page associated with the selected tab
    ref.read(routerProvider).dispatch(widget.tabs[tabIndex].intent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TabBar(
      indicator: widget.indicator ?? theme.tabBarTheme.indicator,
      controller: _tabController,
      tabs: widget.tabs.map((e) => Tab(text: e.title)).toList(),
      onTap: _onSelectTab,
    );
  }
}
