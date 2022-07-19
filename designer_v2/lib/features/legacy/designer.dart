import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart' as p;

import './designer/eligibility_designer.dart';
import './designer/results_designer.dart';
import 'designer/about_designer.dart';
import 'designer/app_state.dart';
import 'designer/consent_designer.dart';
import 'designer/interventions_designer.dart';
import 'designer/observation_designer.dart';
import 'designer/questionnaire_designer.dart';
import 'designer/report_designer.dart';
import 'designer/schedule_designer.dart';

abstract class RoutePath {}

class HomePath extends RoutePath {}

class DetailsPath extends RoutePath {
  final String? studyId;

  DetailsPath({required this.studyId});
}

class DesignerPath implements DetailsPath {
  static const String basePath = 'designer';
  static const String newPath = 'new';
  final DesignerPage page;
  @override
  final String? studyId;

  bool get isNew => studyId == null;

  DesignerPath({this.studyId, this.page = DesignerPage.about});
}

class NotebookPath extends DetailsPath {
  static const String basePath = 'notebook';
  final String notebook;

  NotebookPath({required String studyId, required this.notebook}) : super(studyId: studyId);
}


class Designer extends StatefulWidget {
  final String? studyId;

  const Designer({required this.studyId}) : super();

  @override
  _DesignerState createState() => _DesignerState();
}

class _DesignerState extends State<Designer> {
  late final DesignerRouterDelegate _designerRouterDelegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    //final appState = context.read<AppState>();
    //appState.createStudy();
    _designerRouterDelegate = DesignerRouterDelegate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context).backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  Future<Study?> saveStudy(BuildContext context, Study study, {bool publish = false}) async {
    if (publish) {
      final publishingAccepted =
          await showDialog<bool>(context: context, builder: (_) => PublishAlertDialog(studyTitle: study.title!));
      if (publishingAccepted == null || !publishingAccepted) return null;
      study.published = true;
    }

    final savedStudy = await study.save();
    if (!mounted) return null;
    if (savedStudy == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${study.title} ${AppLocalizations.of(context)!.failed_saving}')));
      return null;
    }

    final savedMessage = publish
        ? AppLocalizations.of(context)!.was_saved_and_published
        : AppLocalizations.of(context)!.was_saved_as_draft;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${study.title} $savedMessage')),
    );

    return savedStudy;
  }

  @override
  Widget build(BuildContext context) {
    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    final appState = context.watch<AppState>();
    final study = appState.draftStudy;
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(
          study != null
              ? AppLocalizations.of(context)!.view_published_study
              : AppLocalizations.of(context)!.create_new_study,
        ),
        actions: [
          if (appState.loggedIn && (study == null || !study.published || kDebugMode)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.publish),
                label: Text(AppLocalizations.of(context)!.publish_study),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () async {
                  final newStudy = await saveStudy(context, study!, publish: true);
                  if (!mounted) return;
                  if (newStudy != null) context.read<AppState>().openNewStudy(newStudy);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.save_draft),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () async {
                  final newDraftStudy = await saveStudy(context, study!, publish: false);
                  if (!mounted) return;
                  if (newDraftStudy != null) context.read<AppState>().openNewStudy(newDraftStudy);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(MdiIcons.testTube),
                label: const Text('Try draft study'),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () => launchUrl(
                  Uri.parse(
                    '${env.appUrl}${Uri.encodeComponent(Supabase.instance.client.auth.session()!.persistSessionString)}',
                  ),
                ),
              ),
            ),
          ],
          /*
          if (kDebugMode)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await FlutterClipboard.copy(prettyJson(study.toJson()));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.copied_json)));
                },
              ),
            ),
           */
        ],
      ),
       */
      body: Row(
        children: [
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
                        icon: const Icon(Icons.info_outline),
                        selectedIcon: const Icon(Icons.info_outline),
                        label: Text(AppLocalizations.of(context)!.about),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.accessibility_new),
                        selectedIcon: const Icon(Icons.accessibility_new),
                        label: Text(AppLocalizations.of(context)!.interventions),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.question_answer),
                        selectedIcon: const Icon(Icons.question_answer),
                        label: Text(AppLocalizations.of(context)!.eligibility_questions),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.verified_user),
                        selectedIcon: const Icon(Icons.verified_user),
                        label: Text(AppLocalizations.of(context)!.eligibility_criteria),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.zoom_in),
                        selectedIcon: const Icon(Icons.zoom_in),
                        label: Text(AppLocalizations.of(context)!.observations),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.schedule),
                        selectedIcon: const Icon(Icons.schedule),
                        label: Text(AppLocalizations.of(context)!.schedule),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.content_paste),
                        selectedIcon: const Icon(Icons.content_paste),
                        label: Text(AppLocalizations.of(context)!.report),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.assignment_turned_in),
                        selectedIcon: const Icon(Icons.assignment_turned_in),
                        label: Text(AppLocalizations.of(context)!.results),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.warning),
                        selectedIcon: const Icon(Icons.warning),
                        label: Text(AppLocalizations.of(context)!.consent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: Router(
                routerDelegate: _designerRouterDelegate,
                backButtonDispatcher: _backButtonDispatcher,
              ),
             )
          ),
        ],
      ),
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
        //appState.selectedDesignerPage = null;
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

class PublishAlertDialog extends StatelessWidget {
  final String studyTitle;

  const PublishAlertDialog({required this.studyTitle}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.lock_and_publish),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            const TextSpan(text: 'The study '),
            TextSpan(
              text: studyTitle,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextSpan(text: AppLocalizations.of(context)!.really_want_to_publish),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.publish),
          style: ElevatedButton.styleFrom(primary: Colors.green, elevation: 0),
          label: Text('${AppLocalizations.of(context)!.publish} $studyTitle'),
        )
      ],
    );
  }
}
