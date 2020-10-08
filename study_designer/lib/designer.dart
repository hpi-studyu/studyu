import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

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
                Text(body),
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
                title = Nof1Localizations.of(context).translate('meta_data_help_title');
                body = Nof1Localizations.of(context).translate('meta_data_help_body');
                break;
              case designerInterventionsRoute:
                specificDesigner = InterventionsDesigner();
                title = Nof1Localizations.of(context).translate('interventions_help_title');
                body = Nof1Localizations.of(context).translate('interventions_help_body');
                break;
              case designerQuestionnaireRoute:
                specificDesigner = EligibilityQuestionsDesigner();
                title = Nof1Localizations.of(context).translate('eligibility_questions_help_title');
                body = Nof1Localizations.of(context).translate('eligibility_questions_help_body');
                break;
              case designerEligibilityRoute:
                specificDesigner = EligibilityCriteriaDesigner();
                title = Nof1Localizations.of(context).translate('eligibility_criteria_help_title');
                body = Nof1Localizations.of(context).translate('eligibility_criteria_help_body');
                break;
              case designerObservationsRoute:
                specificDesigner = ObservationDesigner();
                title = Nof1Localizations.of(context).translate('observations_help_title');
                body = Nof1Localizations.of(context).translate('observations_help_body');
                break;
              case designerScheduleRoute:
                specificDesigner = ScheduleDesigner();
                title = Nof1Localizations.of(context).translate('schedule_help_title');
                body = Nof1Localizations.of(context).translate('schedule_help_body');
                break;
              case designerReportRoute:
                specificDesigner = ReportDesigner();
                title = Nof1Localizations.of(context).translate('report_help_title');
                body = Nof1Localizations.of(context).translate('report_help_body');
                break;
              case designerResultsRoute:
                specificDesigner = ResultsDesigner();
                title = Nof1Localizations.of(context).translate('results_help_title');
                body = Nof1Localizations.of(context).translate('results_help_body');
                break;
              case designerConsentRoute:
                specificDesigner = ConsentDesigner();
                title = Nof1Localizations.of(context).translate('create_new_study');
                body = Nof1Localizations.of(context).translate('create_new_study');
                break;
              case designerSaveRoute:
                specificDesigner = Save();
                break;
              default:
                specificDesigner = Container();
              //throw Exception('Invalid route: ${settings.name}');
            }

            final Widget specificDesignerWithHelpbar = Column(
              children: [
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
          title: Text(Nof1Localizations.of(context).translate('create_new_study')),
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
                selectedIcon: Icon(Icons.favorite),
                label: Text(Nof1Localizations.of(context).translate('meta_data')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.accessibility_new),
                selectedIcon: Icon(Icons.accessibility_new),
                label: Text(Nof1Localizations.of(context).translate('interventions')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.question_answer),
                selectedIcon: Icon(Icons.question_answer),
                label: Text(Nof1Localizations.of(context).translate('eligibility_questions')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                selectedIcon: Icon(Icons.verified_user),
                label: Text(Nof1Localizations.of(context).translate('eligibility_criteria')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.zoom_in),
                selectedIcon: Icon(Icons.zoom_in),
                label: Text(Nof1Localizations.of(context).translate('observations')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                selectedIcon: Icon(Icons.schedule),
                label: Text(Nof1Localizations.of(context).translate('schedule')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.content_paste),
                selectedIcon: Icon(Icons.content_paste),
                label: Text(Nof1Localizations.of(context).translate('report')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_turned_in),
                selectedIcon: Icon(Icons.assignment_turned_in),
                label: Text(Nof1Localizations.of(context).translate('results')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                selectedIcon: Icon(Icons.warning),
                label: Text(Nof1Localizations.of(context).translate('consent')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.publish),
                selectedIcon: Icon(Icons.publish),
                label: Text(Nof1Localizations.of(context).translate('save')),
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
