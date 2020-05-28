import 'package:flutter/material.dart';

import 'dashboard/contact_tab/contact.dart';
import 'dashboard/dashboard.dart';
import 'dashboard/settings.dart';
import 'onboarding/intervention_selection.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

class Routes {
  static const String dashboard = '/dashboard';
  static const String welcome = '/welcome';
  static const String about = '/about';
  static const String studySelection = '/studySelection';
  static const String interventionSelection = '/interventionSelection';
  static const String contact = '/contact';
  static const String appSettings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) {
          return DashboardScreen.fromRouteArgs(settings.arguments);
        });
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case about:
        return MaterialPageRoute(builder: (_) => AboutScreen());
      case studySelection:
        return MaterialPageRoute(builder: (_) => StudySelectionScreen());
      case interventionSelection:
        return MaterialPageRoute(builder: (_) => InterventionSelection());
      case contact:
        return MaterialPageRoute(builder: (_) => Contact());
      case appSettings:
        return MaterialPageRoute(builder: (_) => Settings());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
