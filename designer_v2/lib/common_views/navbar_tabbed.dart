import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class NavbarTab {
  NavbarTab({
    required this.title,
    this.intent,
    required this.index,
    this.enabled = true,
  });

  /// The text displayed as the tab's title
  final String title; // TODO: use localization key here

  /// The route to navigate to when switching to the tab
  final RoutingIntent? intent;

  final int index;

  final bool enabled;
}

class TabbedNavbar extends ConsumerStatefulWidget {
  const TabbedNavbar({
    required this.tabs,
    this.selectedTab,
    this.indicator,
    this.height,
    this.disabledBackgroundColor,
    this.disabledTooltipText,
    Key? key,
  }) : super(key: key);

  final List<NavbarTab> tabs;
  final NavbarTab? selectedTab;
  final BoxDecoration? indicator;
  final double? height;
  final Color? disabledBackgroundColor;
  final String? disabledTooltipText;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabbedNavbarState();
}

class _TabbedNavbarState extends ConsumerState<TabbedNavbar>
    with TickerProviderStateMixin
    implements Listenable {
  /// A [TabController] that has its index synced to the currently selected
  /// tab provided by the widget. The widget's parameter may be injected e.g.
  /// via a router
  late final TabController _tabController;

  late int _selectedTabIndex =
      widget.selectedTab?.index ?? _findFirstEnabledTabIndex();
  int get selectedTabIndex => _selectedTabIndex;
  set selectedTabIndex(int idx) {
    final tab = widget.tabs[idx];
    final prevIdx = _selectedTabIndex;
    final int newIdx;
    if (!tab.enabled) {
      // prevent selecting disabled tabs
      newIdx = _findFirstEnabledTabIndex();
    } else {
      newIdx = tab.index;
    }
    _selectedTabIndex = newIdx;

    if (prevIdx != newIdx) {
      for (final listener in onTabChangedListeners) {
        listener();
      }
    }
  }

  NavbarTab get selectedTab => widget.tabs[selectedTabIndex];

  /// Registered listeners that are called immediately when changing the
  /// currently selected tab
  ///
  /// Note: [TabController.addListener] default listeners are only called
  /// after the animation has completed
  List<VoidCallback> onTabChangedListeners = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.index = selectedTabIndex;
    addListener(navigateToTabRoute);
  }

  revalidateTabSelection() {
    final currentIdx = selectedTabIndex;
    selectedTabIndex = currentIdx;
  }

  @override
  void didUpdateWidget(TabbedNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    revalidateTabSelection();
    // Sync up the tab controller when a new widget is created
    // (e.g. by navigating to a different page)
    _tabController.animateTo(selectedTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    //_tabController.removeListener(resetDisabledTab);
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    onTabChangedListeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    onTabChangedListeners.remove(listener);
  }

  void navigateToTabRoute() {
    if (!selectedTab.enabled || selectedTab.intent == null) {
      return;
    }
    runAsync(() => ref.read(routerProvider).dispatch(selectedTab.intent!));
  }

  void _onSelectTab(int tabIndex) {
    setState(() {
      selectedTabIndex = tabIndex;
    });
  }

  int _findFirstEnabledTabIndex() {
    for (final t in widget.tabs) {
      if (t.enabled) {
        return t.index;
      }
    }
    throw Exception("Must provide at least one non-disabled tab.");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorSize = (theme.tabBarTheme.indicator as BoxDecoration)
            .border
            ?.dimensions
            .vertical ??
        0.0;

    decorateIfDisabled({required Widget tabContent, required NavbarTab tab}) {
      if (tab.enabled) {
        return tabContent;
      }
      final disablePointerCursor = MouseEventsRegion(
        builder: (context, state) => tabContent,
        cursor: SystemMouseCursors.basic,
      );
      if (widget.disabledTooltipText != null) {
        return Tooltip(
            message: widget.disabledTooltipText!,
            child: disablePointerCursor
        );
      }
      return disablePointerCursor;
    }

    return Theme(
      data: theme.copyWith(splashColor: Colors.transparent),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.8),
        unselectedLabelStyle: theme.textTheme.labelLarge,
        indicator: widget.indicator ?? theme.tabBarTheme.indicator,
        controller: _tabController,
        tabs: widget.tabs
            .map(
              (t) => decorateIfDisabled(
                  tabContent: Container(
                    decoration: (!t.enabled)
                        ? BoxDecoration(
                            color: widget.disabledBackgroundColor,
                            /*border: Border(
                            bottom: BorderSide(width: indicatorSize * 2, color: Colors.red),
                          )
                       */
                          )
                        : null,
                    height: (widget.height != null)
                        ? widget.height! - indicatorSize
                        : null,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(t.title,
                          style: (!t.enabled)
                              ? TextStyle(color: theme.disabledColor.faded(0.5))
                              : null),
                    ),
                  ),
                  tab: t),
            )
            .toList(),
        onTap: _onSelectTab,
      ),
    );
  }
}
