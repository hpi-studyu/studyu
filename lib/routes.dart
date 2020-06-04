import 'package:flutter/material.dart';

import 'app_onboarding/about.dart';
import 'app_onboarding/terms.dart';
import 'app_onboarding/welcome.dart';
import 'dashboard/contact_tab/contact.dart';
import 'dashboard/dashboard.dart';
import 'dashboard/settings.dart';
import 'study_onboarding/eligibility_check.dart';
import 'study_onboarding/intervention_selection.dart';
import 'study_selection/study_selection.dart';

class Routes {
  static const String dashboard = '/dashboard';
  static const String welcome = '/welcome';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String studySelection = '/studySelection';
  static const String eligibilityCheck = '/eligibilityCheck';
  static const String interventionSelection = '/interventionSelection';
  static const String contact = '/contact';
  static const String appSettings = '/settings';

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              body: Center(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No route defined for ${settings.name}.\nThe developers should fix this 👩‍💻'),
              )),
            ));
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeMap = {
      dashboard: (_) => DashboardScreen.fromRouteArgs(settings.arguments),
      welcome: (_) => WelcomeScreen(),
      about: (_) => AboutScreen(),
      terms: (_) => TermsScreen(),
      studySelection: (_) => StudySelectionScreen(),
      eligibilityCheck: (_) => EligibilityCheckScreen.fromRouteArgs(settings.arguments),
      interventionSelection: (_) => InterventionSelectionScreen.fromRouteArgs(settings.arguments),
      contact: (_) => Contact(),
      appSettings: (_) => Settings(),
    };

    if (!routeMap.containsKey(settings.name)) {
      // null will be handled by onUnknownRoute
      return null;
    }

    return MaterialPageRoute(builder: routeMap[settings.name]);
  }
}
