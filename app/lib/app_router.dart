import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_app/screens/study/onboarding/consent.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_app/screens/study/onboarding/kickoff.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_app/screens/study/report/report_details.dart';
import 'package:studyu_app/screens/study/report/report_history.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_core/core.dart';

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
  static const String task = '/task';
  static const String eligibilityCheck = '/eligibilityCheck';
  static const String capturePicture = '/capturePicture';
  static const String study = '/study/:studyId';
  static const String invite = '/invite/:inviteCode';
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
    redirect: (context, state) {
      // Handle custom URL scheme deep links (studyu-app://invite/xxx)
      final uri = state.uri;
      if (uri.scheme == 'studyu-app' || uri.scheme == 'studyu') {
        // For custom schemes, the path is empty and the "path" is in the host
        // e.g., studyu-app://invite/12345678 -> host=invite, path=/12345678
        final path = '/${uri.host}${uri.path}';
        return path;
      }
      // Remove splash screen when navigating away from loading screen
      if (state.uri.path != RoutePaths.loading) {
        FlutterNativeSplash.remove();
      }
      return null; // No redirect, just proceed with the requested route
    },
    routes: _buildRoutes(queryParameters),
  );
}

/// Builds the list of routes for the app
List<RouteBase> _buildRoutes(Map<String, String> queryParameters) {
  return [
      // Root route redirects to loading
      GoRoute(
        path: '/',
        redirect: (context, state) => RoutePaths.loading,
      ),
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
        builder: (context, state) {
          final error = state.extra as String?;
          return DashboardScreen(error: error);
        },
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
      GoRoute(
        path: RoutePaths.task,
        name: 'task',
        builder: (context, state) {
          final taskInstance = state.extra! as TaskInstance;
          return TaskScreen(taskInstance: taskInstance);
        },
      ),
      GoRoute(
        path: RoutePaths.eligibilityCheck,
        name: 'eligibilityCheck',
        builder: (context, state) {
          final study = state.extra as Study?;
          return EligibilityScreen(study: study);
        },
      ),
      GoRoute(
        path: RoutePaths.reportDetails,
        name: 'reportDetails',
        builder: (context, state) {
          final subject = state.extra! as StudySubject;
          return ReportDetailsScreen(subject);
        },
      ),
      GoRoute(
        path: RoutePaths.capturePicture,
        name: 'capturePicture',
        builder: (context, state) {
          final params = state.extra! as Map<String, String>;
          return CapturePictureScreen(
            studyId: params['studyId']!,
            userId: params['userId']!,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.study,
        name: 'study',
        builder: (context, state) {
          final studyId = state.pathParameters['studyId']!;
          return LoadingScreen(deepLinkStudyId: studyId);
        },
      ),
      GoRoute(
        path: RoutePaths.invite,
        name: 'invite',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          return LoadingScreen(deepLinkInviteCode: inviteCode);
        },
      ),
    ],
  );
}
