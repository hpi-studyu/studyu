import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/sidenav_layout.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/theme.dart';


class StudyScaffoldTab {
  StudyScaffoldTab({
    required this.title,
    required this.intent,
    required this.index
  });

  /// The text displayed as the tab's title
  final String title; // TODO: use localization key here
  /// The route to navigate to when switching to the tab
  final RoutingIntentFactory intent;

  final int index;

  static final edit = StudyScaffoldTab(
      index: 0, title: "Design".hardcoded, intent: RoutingIntents.studyEdit);
  static final test = StudyScaffoldTab(
      index: 1, title: "Test".hardcoded, intent: RoutingIntents.studyTest);
  static final recruit = StudyScaffoldTab(
      index: 2, title: "Recruit".hardcoded, intent: RoutingIntents.studyRecruit);
  static final monitor = StudyScaffoldTab(
      index: 3, title: "Monitor".hardcoded, intent: RoutingIntents.studyMonitor);
  static final analyze = StudyScaffoldTab(
      index: 4, title: "Analyze".hardcoded, intent: RoutingIntents.studyAnalyze);

  static List<StudyScaffoldTab> get values =>
      [edit, test, recruit, monitor, analyze];
}

/// Custom scaffold shared between all pages for an individual [Study]
class StudyScaffold extends ConsumerStatefulWidget {
  const StudyScaffold({
    this.studyId = Config.newStudyId,
    required this.selectedTab,
    required this.child,
    Key? key
  }) : super(key: key);

  /// The currently selected [Study.id]
  /// Defaults to [Config.newStudyId] when creating a new study
  final String studyId;

  /// Determines the currently active tab in the app bar's navigation
  final StudyScaffoldTab selectedTab;

  /// The page to be rendered for the currently selected [StudyScaffoldTab]
  final Widget child;

  @override
  ConsumerState<StudyScaffold> createState() => _StudyScaffoldState();
}

class _StudyScaffoldState extends ConsumerState<StudyScaffold>
    with TickerProviderStateMixin {
  /// A [TabController] that has its index synced to the currently selected
  /// tab provided by the widget. The widget's parameter may be injected e.g.
  /// via a router
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: StudyScaffoldTab.values.length,
        vsync: this);
    _tabController.index = widget.selectedTab.index;
  }

  @override
  void didUpdateWidget(StudyScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync up the tab controller when a new widget is created
    // (e.g. by navigating to a different page)
    _tabController.animateTo(widget.selectedTab.index);
  }

  List<Tab> _getTabs() {
    return StudyScaffoldTab.values.map((e) => Tab(text: e.title)).toList();
  }

  void _onSelectTab(int tabIndex) {
    // Navigate to the page associated with the selected tab
    ref.read(routerProvider).dispatch(
        StudyScaffoldTab.values[tabIndex].intent(widget.studyId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(widget.studyId));
    final controller = ref.watch(studyControllerProvider(widget.studyId).notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        title: Row(
          children: [
            // Use the title widget slot to render both the title and a
            // tabbed control for switching between different pages (combined
            // in a [Row] widget).
            //
            // Alternatively, [Appbar.flexibleSpace] would be suitable for
            // rendering the tabbed navigation. But since [Appbar.flexibleSpace]
            // is stacked behind the app bar, we'd have to manually manage
            // responsive layout conflicts (the tabbed control would be overlaid
            // by the app bar widgets).
            Expanded(
              flex: 4,
              child: AsyncValueWidget(
                value: state.study,
                data: (study) => Text(state.titleText,
                    maxLines: 1,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false
                ),
                loading: () => Container(),
                error: (e, str) => Container(),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TabBar(
                  controller: _tabController,
                  tabs: _getTabs(),
                  onTap: _onSelectTab,
                )
              )
            ),
          ],
        ),
        //backgroundColor: theme.colorScheme.primaryContainer,
        // TODO: fallback to [AppBar.bottom] as tabbed navigation slot for small screens
        /*
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Expanded(child:Container(
            color: Colors.red,
            width: double.infinity,
          )
        )),
         */
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: AsyncValueWidget(
              value: state.study,
              data: (study) => Text(state.statusText,
                  maxLines: 1,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.clip,
                  softWrap: false
              ),
              loading: () => Container(),
              error: (e, str) => Container(),
            ),
          ),
          ActionPopUpMenuButton(
            actions: controller.studyActions,
            orientation: Axis.vertical,
            hideOnEmpty: false,
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: state.study,
        data: (study) => TwoColumnLayoutLeftFixedBodyScroll(
          /*
          bodyWidget: Row(
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: ThemeConfig.kMaxContentWidth),
                  child: widget.child,
                )
              ),
            ],
          ),*/
          bodyWidget: widget.child,
          leftWidget: const SizedBox.shrink(),
          dividerWidget: const SizedBox.shrink(),
        ),
      ),
      drawer: AppDrawer(title: 'StudyU'.hardcoded),
    );
  }
}
