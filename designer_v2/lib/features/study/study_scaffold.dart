import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/router.dart';

enum StudyScaffoldTab {
  edit(title: "Edit", page: RouterPage.studyEditor), // TODO: "Edit".hardcoded
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

/// Custom scaffold shared between all pages of an individual [Study]
class StudyScaffold extends StatefulWidget {
  const StudyScaffold({
    this.studyId = Config.newStudyId,
    required this.selectedTab,
    required this.child,
    Key? key
  }) : super(key: key);

  /// The currently selected [Study.id]
  /// Defaults to [Config.newStudyId] when creating a new study
  final String studyId;
  final StudyScaffoldTab selectedTab;

  /// The page to be rendered for the currently selected [StudyScaffoldTab]
  final Widget child;

  @override
  State<StudyScaffold> createState() => _StudyScaffoldState();
}

class _StudyScaffoldState extends State<StudyScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          Expanded(
            flex: 1,
            child: Text("Backpain Interventions (Demo Template)", // TODO: display study title
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,),
          ),
            //Spacer(),
        Expanded(
          flex: 2,
            child: StudyPageNav(studyId: widget.studyId, selectedTab: widget.selectedTab),
        ),
            //Spacer(),
            //SizedBox(width: 1)
            /*
            Spacer(),
            Text("2nd text",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,),
             */
          ],
        ),
        //leading: Text("Breadcrumbs"),
        backgroundColor:theme.colorScheme.primaryContainer,
        /*
        shape: Border(
            bottom: BorderSide(
              color: theme.colorScheme.primaryContainer,
              width: 1
            )
        ),
         */
        // Flexible space is stacked below the app bar so we can use it
        // to display the center navigation
        flexibleSpace: Container(
            //alignment: Alignment.topCenter,
          alignment: Alignment.center,
          //child: StudyPageNav(studyId: widget.studyId, selectedTab: widget.selectedTab)
        ),
        /*
        bottom: widget.selectedTab == StudyScaffoldTab.edit ? PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Expanded(child:Container(
            color: Colors.red,
            width: double.infinity,
          )
        )) : null,
         */
        actions: [
          Container(
            alignment: Alignment.center,
            child: Text("Status: Draft")
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              child: Text("Save draft"),
              onPressed: () => print("pressed"),
            )
          )
        ],
      ),
      body: widget.child,
      drawer: AppDrawer(title: 'StudyU'.hardcoded),
    );
  }
}

class StudyPageNav extends ConsumerStatefulWidget {
  const StudyPageNav({
    required this.studyId,
    required this.selectedTab,
    Key? key
  }) : super(key: key);

  final String studyId;
  final StudyScaffoldTab selectedTab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudyPageNavState();
}

class _StudyPageNavState extends ConsumerState<StudyPageNav> with TickerProviderStateMixin {
  late TabController _tabController;
  late GoRouter _router;
  int _selectedIndex = 0;

  @override
  void initState() {
    print("_StudyPageNavState.INITSTATE");
    super.initState();
    _tabController = TabController(length: StudyScaffoldTab.values.length, vsync: this);
    _setSelectedIndex(widget.selectedTab.index);
    _router = ref.read(routerProvider);
    _router.addListener(_syncTabsWithRoute);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      final tab = StudyScaffoldTab.values[_selectedIndex];
      final routerPage;
      switch(tab) {
        case StudyScaffoldTab.edit:
          routerPage = RouterPage.studyEditor;
          break;
        case StudyScaffoldTab.recruit:
          routerPage = RouterPage.studyRecruit;
          break;
        default:
          routerPage = RouterPage.studyEditor;
      }
      context.goNamed(routerPage.id, params: {"studyId": widget.studyId});
      print("Selected tab index: " + _tabController.index.toString());
    });
    _syncTabsWithRoute();
  }

  @override
  void didUpdateWidget(StudyPageNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("_StudyPageNavState.DID UPDATE WIDGET");
    _setSelectedIndex(widget.selectedTab.index);
    //_controller.index = widget.index;
  }


  _syncTabsWithRoute() {
    print("SYNC");
    print("_syncTabsWithRoute: " + _router.currentPath);
    switch(_router.currentPath) {
      case RouterPage.studyEditor:
        _setSelectedIndex(StudyScaffoldTab.edit.index);
        break;
      case RouterPage.studyRecruit:
        _setSelectedIndex(StudyScaffoldTab.recruit.index);
        break;
      default:
        break;
    }
  }

  _setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.animateTo(_selectedIndex);
    //_tabController.index = _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    print("_StudyPageNavState.build");
    return Container(child: SizedBox(
      width: 300,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: "Edit"),
          //Tab(text: "Test"),
          Tab(text: "Recruit"),
        ],

      )
    ));
  }
}
