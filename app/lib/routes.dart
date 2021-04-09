import 'package:flutter/material.dart';

import 'screens/app_onboarding/about.dart';
import 'screens/app_onboarding/loading_screen.dart';
import 'screens/app_onboarding/terms.dart';
import 'screens/app_onboarding/welcome.dart';
import 'screens/study/dashboard/contact_tab/contact_screen.dart';
import 'screens/study/dashboard/contact_tab/faq.dart';
import 'screens/study/dashboard/dashboard.dart';
import 'screens/study/dashboard/settings.dart';
import 'screens/study/onboarding/consent.dart';
import 'screens/study/onboarding/intervention_selection.dart';
import 'screens/study/onboarding/journey_overview.dart';
import 'screens/study/onboarding/kickoff.dart';
import 'screens/study/onboarding/study_overview.dart';
import 'screens/study/onboarding/study_selection.dart';
import 'screens/study/report/report_history.dart';

class Routes {
  static const String loading = '/loading';
  static const String dashboard = '/dashboard';
  static const String welcome = '/welcome';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String studySelection = '/studySelection';
  static const String studyOverview = '/studyOverview';
  static const String interventionSelection = '/interventionSelection';
  static const String journey = '/journey';
  static const String consent = '/consent';
  static const String kickoff = '/kickoff';
  static const String contact = '/contact';
  static const String faq = '/faq';
  static const String appSettings = '/settings';
  static const String questionnaire = '/questionnaire';
  static const String reportHistory = '/reportHistory';
  static const String reportDetails = '/reportDetails';
  static const String performanceDetails = '/performanceDetails';

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              body: SafeArea(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No route defined for ${settings.name}.\nThe developers should fix this 👩‍💻'),
                )),
              ),
            ));
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // init Parse on our initial route
      case loading:
        return MaterialPageRoute(builder: (_) => LoadingScreen(), settings: settings);
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen(), settings: settings);
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen(), settings: settings);
      case about:
        return MaterialPageRoute(builder: (_) => AboutScreen(), settings: settings);
      case terms:
        return MaterialPageRoute(builder: (_) => TermsScreen(), settings: settings);
      case studySelection:
        return MaterialPageRoute(builder: (_) => StudySelectionScreen(), settings: settings);
      case studyOverview:
        return MaterialPageRoute(builder: (_) => StudyOverviewScreen(), settings: settings);
      case interventionSelection:
        return MaterialPageRoute(builder: (_) => InterventionSelectionScreen(), settings: settings);
      case journey:
        return MaterialPageRoute(builder: (_) => JourneyOverviewScreen(), settings: settings);
      case consent:
        return MaterialPageRoute<bool>(builder: (_) => ConsentScreen(), settings: settings);
      case kickoff:
        return MaterialPageRoute(builder: (_) => KickoffScreen(), settings: settings);
      case contact:
        return MaterialPageRoute(builder: (_) => ContactScreen(), settings: settings);
      case faq:
        return MaterialPageRoute(builder: (_) => FAQ(), settings: settings);
      case appSettings:
        return MaterialPageRoute(builder: (_) => Settings(), settings: settings);
      case reportHistory:
        return MaterialPageRoute(builder: (_) => ReportHistoryScreen(), settings: settings);
      default:
        // null will be handled by onUnknownRoute
        return null;
    }
  }
}
