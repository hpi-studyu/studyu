import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import './designer/eligibility_designer.dart';
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

  Widget buildDesignerRouter() => Expanded(
        child: Navigator(
          key: _navigatorKey,
          initialRoute: widget.route,
          onGenerateRoute: (settings) {
            if (_selectedIndex != designerRoutes.indexOf(settings.name)) {
              _selectedIndex = designerRoutes.indexOf(settings.name);
            }
            WidgetBuilder builder;
            switch (settings.name) {
              case designerRoute:
                builder = (context) => MetaDataDesigner();
                break;
              case designerInterventionsRoute:
                builder = (context) => InterventionsDesigner();
                break;
              case designerQuestionnaireRoute:
                builder = (context) => QuestionnaireDesigner();
                break;
              case designerEligibilityRoute:
                builder = (context) => EligibilityDesigner();
                break;
              case designerObservationsRoute:
                builder = (context) => ObservationDesigner();
                break;
              case designerScheduleRoute:
                builder = (context) => ScheduleDesigner();
                break;
              case designerReportRoute:
                builder = (context) => ReportDesigner();
                break;
              case designerConsentRoute:
                builder = (context) => ConsentDesigner();
                break;
              case designerSaveRoute:
                builder = (context) => Save();
                break;
              default:
                builder = (context) => Container();
              //throw Exception('Invalid route: ${settings.name}');
            }
            // You can also return a PageRouteBuilder and
            // define custom transitions between pages
            return MaterialPageRoute(
              builder: builder,
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
    designerConsentRoute,
    designerSaveRoute,
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<DesignerState>.value(
      value: _designerState,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create New Study'),
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
                label: Text('Meta Data'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.accessibility_new),
                selectedIcon: Icon(Icons.accessibility_new),
                label: Text('Interventions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.question_answer),
                selectedIcon: Icon(Icons.question_answer),
                label: Text('Questionnaire'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                selectedIcon: Icon(Icons.verified_user),
                label: Text('Eligibility'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.zoom_in),
                selectedIcon: Icon(Icons.zoom_in),
                label: Text('Observations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.content_paste),
                selectedIcon: Icon(Icons.content_paste),
                label: Text('Report'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                selectedIcon: Icon(Icons.warning),
                label: Text('Consent'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.publish),
                selectedIcon: Icon(Icons.publish),
                label: Text('Save'),
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
