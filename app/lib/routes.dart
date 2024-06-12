// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/app_outdated_screen.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/contact_screen.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/faq.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';
import 'package:studyu_app/screens/study/onboarding/consent.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_app/screens/study/onboarding/kickoff.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_app/screens/study/report/report_history.dart';

class Routes {
  static const String loading = '/loading';
  static const String preview = '/preview';
  static const String appOutdated = '/appOutdated';
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
              child: Text(
                  'No route defined for ${settings.name}.\nThe developers should fix this 👩‍💻',),
            ),
          ),
        ),
      ),
    );
  }

  static Route<dynamic>? generateRoute(
      RouteSettings settings, Map<String, String> queryParameters,) {
    final uri = Uri.parse(settings.name!);
    switch (uri.path) {
      case loading:
        return MaterialPageRoute(
            builder: (_) => const LoadingScreen(), settings: settings,);
      case preview:
        return MaterialPageRoute(
            builder: (_) => LoadingScreen(queryParameters: queryParameters),
            settings: settings,);
      case appOutdated:
        return MaterialPageRoute(
            builder: (_) => const AppOutdatedScreen(), settings: settings,);
      case dashboard:
        return MaterialPageRoute(
            builder: (_) => const DashboardScreen(), settings: settings,);
      case welcome:
        return MaterialPageRoute(
            builder: (_) => const WelcomeScreen(), settings: settings,);
      case about:
        return MaterialPageRoute(
            builder: (_) => const AboutScreen(), settings: settings,);
      case terms:
        return MaterialPageRoute(
            builder: (_) => const TermsScreen(), settings: settings,);
      case studySelection:
        return MaterialPageRoute(
            builder: (_) => const StudySelectionScreen(), settings: settings,);
      case studyOverview:
        return MaterialPageRoute(
            builder: (_) => const StudyOverviewScreen(), settings: settings,);
      case interventionSelection:
        return MaterialPageRoute(
            builder: (_) => const InterventionSelectionScreen(),
            settings: settings,);
      case journey:
        return MaterialPageRoute(
            builder: (_) => const JourneyOverviewScreen(), settings: settings,);
      case consent:
        return MaterialPageRoute<bool>(
            builder: (_) => const ConsentScreen(), settings: settings,);
      case kickoff:
        return MaterialPageRoute(
            builder: (_) => const KickoffScreen(), settings: settings,);
      case contact:
        return MaterialPageRoute(
            builder: (_) => const ContactScreen(), settings: settings,);
      case faq:
        return MaterialPageRoute(
            builder: (_) => const FAQ(), settings: settings,);
      case appSettings:
        return MaterialPageRoute(
            builder: (_) => const Settings(), settings: settings,);
      case reportHistory:
        return MaterialPageRoute(
            builder: (_) => const ReportHistoryScreen(), settings: settings,);
      default:
        //final potentialSessionString = Uri.decodeComponent(settings.name.replaceFirst('/', ''));
        //return MaterialPageRoute(builder: (_) => LoadingScreen(sessionString: potentialSessionString));
        // null will be handled by onUnknownRoute
        return null;
    }
  }
}
