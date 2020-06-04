import 'package:flutter/material.dart';

import 'dashboard/contact_tab/contact.dart';
import 'dashboard/dashboard.dart';
import 'dashboard/settings.dart';
import 'onboarding/eligibility_check.dart';
import 'onboarding/intervention_selection.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

class Routes {
  static const String dashboard = '/dashboard';
  static const String welcome = '/welcome';
  static const String about = '/about';
  static const String studySelection = '/studySelection';
  static const String eligibilityCheck = '/eligibilityCheck';
  static const String interventionSelection = '/interventionSelection';
  static const String contact = '/contact';
  static const String appSettings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeMap = {
      dashboard: (_) => DashboardScreen.fromRouteArgs(settings.arguments),
      welcome: (_) => WelcomeScreen(),
      about: (_) => AboutScreen(),
      studySelection: (_) => StudySelectionScreen(),
      eligibilityCheck: (_) => EligibilityCheckScreen.fromRouteArgs(settings.arguments),
      interventionSelection: (_) => InterventionSelectionScreen.fromRouteArgs(settings.arguments),
      contact: (_) => Contact(),
      appSettings: (_) => Settings(),
    };

    Widget unknownRouteScreen(_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        );

    return MaterialPageRoute(builder: routeMap[settings.name] ?? unknownRouteScreen);
  }
}
