import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_page.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/features/auth/login_page.dart';
import 'package:studyu_designer_v2/common_views/pages/splash_page.dart';
import 'package:studyu_designer_v2/features/legacy/designer_page.dart';
import 'package:studyu_designer_v2/features/study/study_analyze_page.dart';
import 'package:studyu_designer_v2/features/study/study_monitor_page.dart';
import 'package:studyu_designer_v2/features/study/study_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_edit_page.dart';
import 'package:studyu_designer_v2/features/study/study_recruit_page.dart';
import 'package:studyu_designer_v2/features/study/study_test_page.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/utils/combined_stream_notifier.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';

/// To create a new page:
/// 1) add an entry to the [RouterPage] enum
/// 2) add the page widget to the [routes] list

/// List of all pages in the application
enum RouterPage {
  dashboard(id: "dashboard", path: "/studies"),
    dashboardOwned(id: "dashboardOwned", path: "owned"),
    dashboardShared(id: "dashboardShared", path: "shared"),
    registry(id: "registry", path: "registry"),

  study(id: "study", path: "/study/:studyId"), // studyId or 'new'
    studyEditor(id: "studyEditor", path: "edit"),
    studyTester(id: "studyTester", path: "test"),
    studyMonitor(id: "studyMonitor", path: "monitor"),
    studyRecruit(id: "studyRecruiting", path: "recruit"),
    studyAnalysis(id: "studyAnalysis", path: "analyze"),
  splash(id: "splash", path: "/splash"),
  login(id: "login", path: "/login"),
  error(id: "error", path: "/error");

  final String id;
  final String path;

  const RouterPage({required this.id, required this.path});

  ValueKey get valueKey => ValueKey<String>(id);
}

/// Each route defines a mapping between the URL path and Flutter widget
final List<GoRoute> routes = [
  GoRoute(
    path: RouterPage.dashboard.path,
    name: RouterPage.dashboard.id,
    builder: (context, state) => DashboardScreen(),
    routes: [
      GoRoute(
        path: RouterPage.dashboardOwned.path,
        name: RouterPage.dashboardOwned.id,
        pageBuilder: (context, state) => MaterialPage(
            key: RouterPage.dashboard.valueKey, // shared key
            child: DashboardScreen()
        )
      ),
      GoRoute(
        path: RouterPage.dashboardShared.path,
        name: RouterPage.dashboardShared.id,
        pageBuilder: (context, state) => MaterialPage(
            key: RouterPage.dashboard.valueKey, // shared key
            child: DashboardScreen()
        )
      ),
      GoRoute(
        path: RouterPage.registry.path,
        name: RouterPage.registry.id,
        pageBuilder: (context, state) => MaterialPage(
            key: RouterPage.dashboard.valueKey, // shared key
            child: DashboardScreen()
        )
      ),
    ]
  ),
  GoRoute(
    path: RouterPage.study.path,
    name: RouterPage.study.id,
    redirect: (GoRouterState state) => state.namedLocation(
        RouterPage.studyEditor.id,
        params: {'studyId': state.params['studyId']!}
    ),
    routes: [
      GoRoute(
        path: RouterPage.studyEditor.path,
        name: RouterPage.studyEditor.id,
        pageBuilder: (context, state) => MaterialPage(
          key: RouterPage.study.valueKey, // shared key
          child: StudyScaffold(
            studyId: state.params['studyId']!,
            selectedTab: StudyScaffoldTab.edit,
            // TODO: replace legacy editor with new version
            //child: StudyEditScreen(state.params['studyId']!)
            child: DesignerScreen(state.params['studyId']!),
          )
        )
      ),
      GoRoute(
        path: RouterPage.studyTester.path,
        name: RouterPage.studyTester.id,
        pageBuilder: (context, state) => MaterialPage(
          key: RouterPage.study.valueKey, // shared key
          child: StudyScaffold(
              studyId: state.params['studyId']!,
              selectedTab: StudyScaffoldTab.test,
              child: StudyTestScreen(state.params['studyId']!)
          )
        )
      ),
      GoRoute(
          path: RouterPage.studyRecruit.path,
          name: RouterPage.studyRecruit.id,
          pageBuilder: (context, state) => MaterialPage(
              key: RouterPage.study.valueKey, // shared key
              child: StudyScaffold(
                  studyId: state.params['studyId']!,
                  selectedTab: StudyScaffoldTab.recruit,
                  child: StudyRecruitScreen(state.params['studyId']!)
              )
          )
      ),
      GoRoute(
          path: RouterPage.studyMonitor.path,
          name: RouterPage.studyMonitor.id,
          pageBuilder: (context, state) => MaterialPage(
              key: RouterPage.study.valueKey, // shared key
              child: StudyScaffold(
                  studyId: state.params['studyId']!,
                  selectedTab: StudyScaffoldTab.monitor,
                  child: StudyMonitorScreen(state.params['studyId']!)
              )
          )
      ),
      GoRoute(
          path: RouterPage.studyAnalysis.path,
          name: RouterPage.studyAnalysis.id,
          pageBuilder: (context, state) => MaterialPage(
              key: RouterPage.study.valueKey, // shared key
              child: StudyScaffold(
                  studyId: state.params['studyId']!,
                  selectedTab: StudyScaffoldTab.analyze,
                  child: StudyAnalyzeScreen(state.params['studyId']!)
              )
          )
      ),
    ]
  ),
  GoRoute(
    path: RouterPage.splash.path,
    name: RouterPage.splash.id,
    builder: (context, state) => SplashPage(),
  ),
  GoRoute(
    path: RouterPage.login.path,
    name: RouterPage.login.id,
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: RouterPage.error.path,
    name: RouterPage.error.id,
    pageBuilder: (context, state) => MaterialPage(
      key: RouterPage.error.valueKey, // shared key
      child: ErrorPage(error: state.extra as Exception)
    )
    //builder: (context, state) => ErrorPage(error: state.extra.toString()),
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final appController = ref.read(appControllerProvider.notifier);
  final defaultLocation = RouterPage.dashboard.path;

  return GoRouter(
    refreshListenable: CombinedStreamNotifier([
      // Any stream registered here will trigger the router's redirect logic
      appController.stream,                   // initialization events
      authRepository.watchAuthStateChanges()  // authentication events
    ]),
    initialLocation: defaultLocation,
    routes: routes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (state) {
      debugLog("Router redirect: ${state.location}");

      final loginLocation = state.namedLocation(RouterPage.login.id);
      final splashLocation = state.namedLocation(RouterPage.splash.id);
      final isOnDefaultPage = state.subloc == defaultLocation;
      final isOnLoginPage = state.subloc == loginLocation;
      final isOnSplashPage = state.subloc == splashLocation;

      // Read most recent app state on re-evaluation (see refreshListenable)
      final isLoggedIn = authRepository.isLoggedIn;
      final isInitialized = appController.isInitialized;

      // Carry original location through the redirect flow so that we can
      // redirect the user to where the came from after initialization
      final String? from;
      if (state.queryParams.containsKey('from')) {
        from = state.queryParams['from'];
      } else {
        if (!(isOnDefaultPage | isOnLoginPage | isOnSplashPage)) {
          from = state.subloc;
        } else {
          from = null;
        }
      }
      // Helper to generate routes carrying the 'from' param (if any)
      namedLocForwarded(String name) {
        final Map<String,String> qParams = {};
        if (from != null) {
          qParams["from"] = from;
        }
        return state.namedLocation(name, queryParams: qParams);
      }

      if (!isInitialized) {
        // Redirect to splash screen while app is pending initialization
        return (isOnSplashPage) ? null : namedLocForwarded(RouterPage.splash.id);
      }
      if (!isLoggedIn) {
        // Redirect to login page when not logged in
        return (isOnLoginPage) ? null : namedLocForwarded(RouterPage.login.id);
      }

      if (isInitialized && isLoggedIn) {
        // If the app is initialized & user is authenticated, forward to where
        // they were going initially...
        if (from != null && from != state.subloc) {
          return from;
        }
        // ...or send them to the default location if they just authenticated
        // and weren't going anywhere
        if (isOnLoginPage || isOnSplashPage) {
          return defaultLocation;
        }
      }

      return null; // don't redirect in all other cases
    },
    // Turn off the # in the URLs on the web
    urlPathStrategy: UrlPathStrategy.path,
  );
});

extension RouterConvencienceX on GoRouter {
  get currentPath => routerDelegate.currentConfiguration.path;
}
