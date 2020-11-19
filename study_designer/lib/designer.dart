import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import './designer/eligibility_designer.dart';
import './designer/results_designer.dart';
import 'designer/consent_designer.dart';
import 'designer/interventions_designer.dart';
import 'designer/meta_data_designer.dart';
import 'designer/observation_designer.dart';
import 'designer/questionnaire_designer.dart';
import 'designer/report_designer.dart';
import 'designer/save.dart';
import 'designer/schedule_designer.dart';
import 'models/designer_state.dart';
import 'routes.dart';

class Designer extends StatefulWidget {
  final String route;
  final StudyBase study;

  const Designer({@required this.route, this.study}) : super();

  static MaterialPageRoute draftRoute({@required StudyBase study}) => MaterialPageRoute(
      builder: (_) => Designer(route: designerRoute, study: study), settings: RouteSettings(name: designerRoute));

  @override
  _DesignerState createState() => _DesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _DesignerState extends State<Designer> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;
  DesignerState _designerState;

  @override
  void initState() {
    super.initState();
    _selectedIndex = designerRoutes.indexOf(widget.route);
    _designerState = DesignerState();
    if (widget.study != null) _designerState.draftStudy = widget.study;
  }

  Future<void> _showHelpDialog(title, body) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body, overflow: TextOverflow.clip),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDesignerRouter() => Expanded(
        child: Navigator(
          key: _navigatorKey,
          initialRoute: widget.route,
          onGenerateRoute: (settings) {
            if (_selectedIndex != designerRoutes.indexOf(settings.name)) {
              _selectedIndex = designerRoutes.indexOf(settings.name);
            }
            Widget specificDesigner;
            String title;
            String body;
            switch (settings.name) {
              case designerRoute:
                specificDesigner = MetaDataDesigner();
                title = AppLocalizations.of(context).meta_data_help_title;
                body = AppLocalizations.of(context).meta_data_help_body;
                break;
              case designerInterventionsRoute:
                specificDesigner = InterventionsDesigner();
                title = AppLocalizations.of(context).interventions_help_title;
                body = AppLocalizations.of(context).interventions_help_body;
                break;
              case designerQuestionnaireRoute:
                specificDesigner = EligibilityQuestionsDesigner();
                title = AppLocalizations.of(context).eligibility_questions_help_title;
                body = AppLocalizations.of(context).eligibility_questions_help_body;
                break;
              case designerEligibilityRoute:
                specificDesigner = EligibilityCriteriaDesigner();
                title = AppLocalizations.of(context).eligibility_criteria_help_title;
                body = AppLocalizations.of(context).eligibility_criteria_help_body;
                break;
              case designerObservationsRoute:
                specificDesigner = ObservationDesigner();
                title = AppLocalizations.of(context).observations_help_title;
                body = AppLocalizations.of(context).observations_help_body;
                break;
              case designerScheduleRoute:
                specificDesigner = ScheduleDesigner();
                title = AppLocalizations.of(context).schedule_help_title;
                body = AppLocalizations.of(context).schedule_help_body;
                break;
              case designerReportRoute:
                specificDesigner = ReportDesigner();
                title = AppLocalizations.of(context).report_help_title;
                body = AppLocalizations.of(context).report_help_body;
                break;
              case designerResultsRoute:
                specificDesigner = ResultsDesigner();
                title = AppLocalizations.of(context).results_help_title;
                body = AppLocalizations.of(context).results_help_body;
                break;
              case designerConsentRoute:
                specificDesigner = ConsentDesigner();
                title = AppLocalizations.of(context).consent_help_title;
                body = AppLocalizations.of(context).consent_help_body;
                break;
              case designerSaveRoute:
                specificDesigner = Save();
                title = AppLocalizations.of(context).save_help_title;
                body = AppLocalizations.of(context).save_help_body;
                break;
              default:
                specificDesigner = Container();
              //throw Exception('Invalid route: ${settings.name}');
            }

            final Widget specificDesignerWithHelpbar = Column(
              children: [
                if (widget.study != null && widget.study.published)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      AppLocalizations.of(context).view_mode_warning,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Row(children: [
                  Spacer(),
                  IconButton(icon: Icon(Icons.help), onPressed: () => _showHelpDialog(title, body))
                ]),
                Expanded(child: specificDesigner),
              ],
            );
            // You can also return a PageRouteBuilder and
            // define custom transitions between pages
            return MaterialPageRoute(
              builder: (context) => specificDesignerWithHelpbar,
              settings: settings,
            );
          },
        ),
      );

  final List<String> designerRoutes = [
    designerRoute,
    designerInterventionsRoute,
    designerQuestionnaireRoute,
    designerEligibilityRoute,
    designerObservationsRoute,
    designerScheduleRoute,
    designerReportRoute,
    designerResultsRoute,
    designerConsentRoute,
    designerSaveRoute,
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<DesignerState>.value(
      value: _designerState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.study != null
              ? AppLocalizations.of(context).view_published_study
              : AppLocalizations.of(context).create_new_study),
          actions: [
            kReleaseMode
                ? Container()
                : Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () async {
                            await FlutterClipboard.copy(prettyJson(widget.study.toJson()));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).copied_json)));
                          },
                        )),
          ],
        ),
        body: Row(children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _navigatorKey.currentState.pushReplacementNamed(designerRoutes[_selectedIndex]);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.info_outline),
                label: Text(AppLocalizations.of(context).meta_data),
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
              if (!(widget.study != null && widget.study.published))
                NavigationRailDestination(
                  icon: Icon(Icons.publish),
                  selectedIcon: Icon(Icons.publish),
                  label: Text(AppLocalizations.of(context).save),
                )
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          buildDesignerRouter()
        ]),
      ),
    );
  }
}
