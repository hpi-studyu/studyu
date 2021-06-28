import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:url_launcher/url_launcher.dart';

import './designer/eligibility_designer.dart';
import './designer/results_designer.dart';
import 'designer/about_designer.dart';
import 'designer/consent_designer.dart';
import 'designer/interventions_designer.dart';
import 'designer/observation_designer.dart';
import 'designer/questionnaire_designer.dart';
import 'designer/report_designer.dart';
import 'designer/save.dart';
import 'designer/schedule_designer.dart';
import 'models/app_state.dart';
import 'router.dart';

class Designer extends StatefulWidget {
  final String studyId;

  const Designer({@required this.studyId}) : super();

  @override
  _DesignerState createState() => _DesignerState();
}

class _DesignerState extends State<Designer> {
  DesignerRouterDelegate _designerRouterDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    _designerRouterDelegate = DesignerRouterDelegate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context).backButtonDispatcher.createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    final appState = context.watch<AppState>();
    final study = appState.draftStudy;
    return Scaffold(
      appBar: AppBar(
        title: Text(study != null
            ? AppLocalizations.of(context).view_published_study
            : AppLocalizations.of(context).create_new_study),
        actions: [
          if (!study.published)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: Icon(MdiIcons.testTube),
                label: Text('Try draft study'),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () =>
                    launch('${env.appUrl}${Uri.encodeComponent(env.client.auth.session().persistSessionString)}'),
              ),
            ),
          if (kDebugMode)
            Builder(
                builder: (context) => IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () async {
                        await FlutterClipboard.copy(prettyJson(study.toJson()));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).copied_json)));
                      },
                    )),
        ],
      ),
      body: Row(children: [
        LayoutBuilder(
            builder: (context, constraint) => SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: appState.selectedDesignerPage.index,
                      onDestinationSelected: (int index) {
                        appState.selectedDesignerPage = DesignerPage.values[index];
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.info_outline),
                          selectedIcon: Icon(Icons.info_outline),
                          label: Text(AppLocalizations.of(context).about),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.accessibility_new),
                          selectedIcon: Icon(Icons.accessibility_new),
                          label: Text(AppLocalizations.of(context).interventions),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.question_answer),
                          selectedIcon: Icon(Icons.question_answer),
                          label: Text(AppLocalizations.of(context).eligibility_questions),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.verified_user),
                          selectedIcon: Icon(Icons.verified_user),
                          label: Text(AppLocalizations.of(context).eligibility_criteria),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.zoom_in),
                          selectedIcon: Icon(Icons.zoom_in),
                          label: Text(AppLocalizations.of(context).observations),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.schedule),
                          selectedIcon: Icon(Icons.schedule),
                          label: Text(AppLocalizations.of(context).schedule),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.content_paste),
                          selectedIcon: Icon(Icons.content_paste),
                          label: Text(AppLocalizations.of(context).report),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.assignment_turned_in),
                          selectedIcon: Icon(Icons.assignment_turned_in),
                          label: Text(AppLocalizations.of(context).results),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.warning),
                          selectedIcon: Icon(Icons.warning),
                          label: Text(AppLocalizations.of(context).consent),
                        ),
                        if (study == null || !study.published || kDebugMode)
                          NavigationRailDestination(
                            icon: Icon(Icons.publish),
                            selectedIcon: Icon(Icons.publish),
                            label: Text(AppLocalizations.of(context).save),
                          )
                      ],
                    ),
                  ),
                ))),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Router(
            routerDelegate: _designerRouterDelegate,
            backButtonDispatcher: _backButtonDispatcher,
          ),
        ),
      ]),
    );
  }
}

class DesignerRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  DesignerRouterDelegate();

  Widget selectedEditor(DesignerPage selectedPage) {
    switch (selectedPage) {
      case DesignerPage.about:
        return AboutDesigner();
      case DesignerPage.interventions:
        return InterventionsDesigner();
      case DesignerPage.eligibilityQuestions:
        return EligibilityQuestionsDesigner();
      case DesignerPage.eligibilityCriteria:
        return EligibilityCriteriaDesigner();
      case DesignerPage.observations:
        return ObservationDesigner();
      case DesignerPage.schedule:
        return ScheduleDesigner();
      case DesignerPage.report:
        return ReportDesigner();
      case DesignerPage.results:
        return ResultsDesigner();
      case DesignerPage.consent:
        return ConsentDesigner();
      case DesignerPage.save:
        return Save();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey(appState.selectedDesignerPage),
          child: selectedEditor(appState.selectedDesignerPage),
        )
      ],
      onPopPage: (route, result) {
        appState.selectedDesignerPage = null;
        notifyListeners();
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }
}
