import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
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

/// Route path constants
class RoutePaths {
  static const String loading = '/loading';
  static const String preview = '/preview';
  static const String appOutdated = '/appOutdated';
  static const String appErrorScreen = '/appError';
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
}

/// Creates and configures the GoRouter instance for the app
GoRouter createAppRouter({
  required Map<String, String> queryParameters,
  String initialLocation = RoutePaths.loading,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: RoutePaths.loading,
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: RoutePaths.preview,
        name: 'preview',
        builder: (context, state) =>
            LoadingScreen(queryParameters: queryParameters),
      ),
      GoRoute(
        path: RoutePaths.appOutdated,
        name: 'appOutdated',
        builder: (context, state) => const AppOutdatedScreen(),
      ),
      GoRoute(
        path: RoutePaths.appErrorScreen,
        name: 'appErrorScreen',
        builder: (context, state) {
          final selectedSubjectId = state.extra as String?;
          return AppErrorScreen(selectedSubjectId: selectedSubjectId);
        },
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RoutePaths.terms,
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: RoutePaths.studySelection,
        name: 'studySelection',
        builder: (context, state) => const StudySelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.studyOverview,
        name: 'studyOverview',
        builder: (context, state) => const StudyOverviewScreen(),
      ),
      GoRoute(
        path: RoutePaths.interventionSelection,
        name: 'interventionSelection',
        builder: (context, state) => const InterventionSelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.journey,
        name: 'journey',
        builder: (context, state) => const JourneyOverviewScreen(),
      ),
      GoRoute(
        path: RoutePaths.consent,
        name: 'consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: RoutePaths.kickoff,
        name: 'kickoff',
        builder: (context, state) => const KickoffScreen(),
      ),
      GoRoute(
        path: RoutePaths.contact,
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: RoutePaths.faq,
        name: 'faq',
        builder: (context, state) => const FAQ(),
      ),
      GoRoute(
        path: RoutePaths.appSettings,
        name: 'appSettings',
        builder: (context, state) => const Settings(),
      ),
      GoRoute(
        path: RoutePaths.reportHistory,
        name: 'reportHistory',
        builder: (context, state) => const ReportHistoryScreen(),
      ),
    ],
  );
}
