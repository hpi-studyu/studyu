import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

enum StudyScaffoldTab {
  edit(title: "Design", page: RouterPage.studyEditor), // TODO: "Edit".hardcoded
  test(title: "Test", page: RouterPage.studyTester), // TODO: "Test".hardcoded
  recruit(title: "Recruit", page: RouterPage.studyRecruit), // TODO: "Recruit".hardcoded
  monitor(title: "Monitor", page: RouterPage.studyMonitor), // TODO: "Monitor".hardcoded
  analyze(title: "Analyze", page: RouterPage.studyAnalysis); // TODO: "Analyze".hardcoded

  /// The text displayed as the tab's title
  final String title; // TODO: use localization key here
  /// The route to navigate to when switching to the tab
  final RouterPage page;

  const StudyScaffoldTab({required this.title, required this.page});
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
    _tabController = TabController(length: StudyScaffoldTab.values.length, vsync: this);
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
    context.goNamed(
      StudyScaffoldTab.values[tabIndex].page.id,
      params: {"studyId": widget.studyId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(widget.studyId));
    final controller = ref.watch(studyControllerProvider(widget.studyId).notifier);

    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: theme.colorScheme.primaryContainer,
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
          PopupMenuButton(
            iconSize: 18,
            elevation: 20,
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            onSelected: (ModelAction action) {
              action.onExecute();
            },
            itemBuilder: (BuildContext context) {
              return controller.studyActions.map((action) {
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
        ],
      ),
      body: AsyncValueWidget(
        value: state.study,
        data: (study) => widget.child,
      ),
      drawer: AppDrawer(title: 'StudyU'.hardcoded),
    );
  }
}
