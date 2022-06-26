import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_page.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/features/auth/login_page.dart';
import 'package:studyu_designer_v2/common_views/pages/splash_page.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/utils/combined_stream_notifier.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';

/// To create a new page:
/// 1) add an entry to the [RouterPage] enum
/// 2) add the page widget to the [routes] list

/// List of all pages in the application
enum RouterPage {
  dashboard(title: "dashboard", path: "/"),
  splash(title: "splash", path: "/splash"),
  login(title: "login", path: "/login"),
  error(title: "error", path: "/error");

  final String title;
  final String path;

  const RouterPage({required this.title, required this.path});
}

/// Each route defines a mapping between the URL path and Flutter widget
final List<GoRoute> routes = [
  GoRoute(
    path: RouterPage.dashboard.path,
    name: RouterPage.dashboard.title,
    builder: (context, state) => DashboardScreen(),
  ),
  GoRoute(
    path: RouterPage.splash.path,
    name: RouterPage.splash.title,
    builder: (context, state) => SplashPage(),
  ),
  GoRoute(
    path: RouterPage.login.path,
    name: RouterPage.login.title,
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: RouterPage.error.path,
    name: RouterPage.error.title,
    builder: (context, state) => ErrorPage(error: state.extra.toString()),
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final appController = ref.read(appControllerProvider.notifier);

  return GoRouter(
    refreshListenable: CombinedStreamNotifier([
      // Any stream registered here will trigger the router's redirect logic
      appController.stream,                   // initialization events
      authRepository.watchAuthStateChanges()  // authentication events
    ]),
    initialLocation: RouterPage.dashboard.path,
    routes: routes,
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: (state) {
      debugLog("Router redirect: ${state.location}");
      final loginLocation = state.namedLocation(RouterPage.login.title);
      final splashLocation = state.namedLocation(RouterPage.splash.title);
      final dashboardLocation = state.namedLocation(RouterPage.dashboard.title);
      final isOnLoginPage = state.subloc == loginLocation;
      final isOnDashboard = state.subloc == dashboardLocation;
      final isOnSplashPage = state.subloc == splashLocation;
      // Read most recent app state on re-evaluation (see refreshListenable)
      final isLoggedIn = authRepository.isLoggedIn;
      final isInitialized = appController.isInitialized;

      // Redirect to splash screen while app is pending initialization
      if (!isInitialized) {
        return (isOnSplashPage) ? null : splashLocation;
      }
      // Redirect to login page when not logged in
      if (!isLoggedIn) {
        return (isOnLoginPage) ? null : loginLocation;
      } else {
        // Forward to dashboard after user was authenticated
        return (isOnDashboard) ? null : dashboardLocation;
      }
    }
  );
});

