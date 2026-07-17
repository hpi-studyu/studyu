import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_app/screens/app_onboarding/app_outdated_screen.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/onboarding_screen.dart';
import 'package:studyu_app/screens/app_onboarding/recovery_phrase_screen.dart';
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
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

/// Route name constants
class RouteNames {
  static const String loading = 'loading';
  static const String preview = 'preview';
  static const String appOutdated = 'appOutdated';
  static const String appErrorScreen = 'appError';
  static const String dashboard = 'dashboard';
  static const String welcome = 'welcome';
  static const String onboarding = 'onboarding';
  static const String terms = 'terms';
  static const String recoveryPhrase = 'recoveryPhrase';
  static const String restoreAccount = 'restoreAccount';
  static const String about = 'about';
  static const String studySelection = 'studySelection';
  static const String studyOverview = 'studyOverview';
  static const String interventionSelection = 'interventionSelection';
  static const String journey = 'journey';
  static const String consent = 'consent';
  static const String kickoff = 'kickoff';
  static const String contact = 'contact';
  static const String faq = 'faq';
  static const String appSettings = 'settings';
  static const String questionnaire = 'questionnaire';
  static const String reportHistory = 'reportHistory';
  static const String reportDetails = 'reportDetails';
  static const String performanceDetails = 'performanceDetails';
  static const String task = 'task';
  static const String eligibilityCheck = 'eligibilityCheck';
  static const String capturePicture = 'capturePicture';
  static const String invite = 'invite';
  static const String study = 'study';
}

/// Creates and configures the GoRouter instance for the app
GoRouter createAppRouter({
  required Map<String, String> queryParameters,
  String initialLocation = '/${RouteNames.loading}',
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) {
      if (state.uri.scheme == appScheme) {
        if (state.uri.host == 'invite') {
          final code = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.first
              : '';
          if (code.isNotEmpty) {
            return '/${RouteNames.invite}/$code';
          }
        }

        if (state.uri.host == 'study') {
          final studyId = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.first
              : '';
          if (studyId.isNotEmpty) {
            return '/${RouteNames.study}/$studyId';
          }
        }
      }
      // Remove splash screen when navigating away from loading screen
      if (state.uri.path != '/${RouteNames.loading}') {
        FlutterNativeSplash.remove();
      }
      return null; // No redirect, just proceed with the requested route
    },
    routes: [
      GoRoute(
        path: '/${RouteNames.loading}',
        name: RouteNames.loading,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.preview}',
        name: RouteNames.preview,
        builder: (context, state) =>
            LoadingScreen(queryParameters: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/${RouteNames.appOutdated}',
        name: RouteNames.appOutdated,
        builder: (context, state) => const AppOutdatedScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.appErrorScreen}',
        name: RouteNames.appErrorScreen,
        builder: (context, state) {
          final arguments = switch (state.extra) {
            final AppErrorScreenArguments args => args,
            final String selectedSubjectId => AppErrorScreenArguments(
              selectedSubjectId: selectedSubjectId,
            ),
            _ => const AppErrorScreenArguments(),
          };
          return AppErrorScreen(
            selectedSubjectId: arguments.selectedSubjectId,
            reason: arguments.reason,
          );
        },
      ),
      GoRoute(
        path: '/${RouteNames.dashboard}',
        name: RouteNames.dashboard,
        builder: (context, state) {
          final error = state.extra as String?;
          return DashboardScreen(error: error);
        },
      ),
      GoRoute(
        path: '/${RouteNames.welcome}',
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.onboarding}',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.about}',
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.terms}',
        name: RouteNames.terms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.recoveryPhrase}',
        name: RouteNames.recoveryPhrase,
        builder: (context, state) => const RecoveryPhraseScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.restoreAccount}',
        name: RouteNames.restoreAccount,
        builder: (context, state) => const RestoreAccountScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.studySelection}',
        name: RouteNames.studySelection,
        builder: (context, state) => const StudySelectionScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.studyOverview}',
        name: RouteNames.studyOverview,
        builder: (context, state) => const StudyOverviewScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.interventionSelection}',
        name: RouteNames.interventionSelection,
        builder: (context, state) => const InterventionSelectionScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.journey}',
        name: RouteNames.journey,
        builder: (context, state) => const JourneyOverviewScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.consent}',
        name: RouteNames.consent,
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.kickoff}',
        name: RouteNames.kickoff,
        builder: (context, state) => const KickoffScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.contact}',
        name: RouteNames.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.faq}',
        name: RouteNames.faq,
        builder: (context, state) => const FAQ(),
      ),
      GoRoute(
        path: '/${RouteNames.appSettings}',
        name: RouteNames.appSettings,
        builder: (context, state) => const Settings(),
      ),
      GoRoute(
        path: '/${RouteNames.reportHistory}',
        name: RouteNames.reportHistory,
        builder: (context, state) => const ReportHistoryScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.task}',
        name: RouteNames.task,
        builder: (context, state) {
          final taskInstance = state.extra as TaskInstance?;
          if (taskInstance == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: Text('Error: Task instance not provided')),
              ),
            );
          }
          return TaskScreen(taskInstance: taskInstance);
        },
      ),
      GoRoute(
        path: '/${RouteNames.eligibilityCheck}',
        name: RouteNames.eligibilityCheck,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is EligibilityScreenArguments) {
            return EligibilityScreen(
              study: extra.study,
              onEligible: extra.onEligible,
            );
          }
          return EligibilityScreen(study: extra as Study?);
        },
      ),
      GoRoute(
        path: '/${RouteNames.reportDetails}',
        name: RouteNames.reportDetails,
        builder: (context, state) {
          final subject = state.extra as StudySubject?;
          if (subject == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: Text('Error: Subject not provided')),
              ),
            );
          }
          return ReportDetailsScreen(subject);
        },
      ),
      GoRoute(
        path: '/${RouteNames.capturePicture}',
        name: RouteNames.capturePicture,
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          if (params == null ||
              params['studyId'] == null ||
              params['userId'] == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text('Error: Missing required parameters'),
                ),
              ),
            );
          }
          return CapturePictureScreen(
            studyId: params['studyId']!,
            userId: params['userId']!,
          );
        },
      ),
      GoRoute(
        path: '/${RouteNames.invite}/:code',
        name: RouteNames.invite,
        builder: (context, state) =>
            LoadingScreen(deepLinkInviteCode: state.pathParameters['code']),
      ),
      GoRoute(
        path: '/${RouteNames.study}/:id',
        name: RouteNames.study,
        builder: (context, state) =>
            LoadingScreen(deepLinkStudyId: state.pathParameters['id']),
      ),
    ],
  );
}
