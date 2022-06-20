import 'package:designer_v2/pages/error_page.dart';
import 'package:designer_v2/pages/login_page.dart';
import 'package:designer_v2/pages/splash_page.dart';
import 'package:designer_v2/features/dashboard/dashboard_page.dart';
import 'package:designer_v2/services/app_service.dart';
import 'package:go_router/go_router.dart';

// List of all pages in the application
// To create a new page, 1) add an entry to the enum and 2) add the page to the AppRouter class
enum RouterPage {
  dashboard(title: "dashboard", path: "/"),
  splash(title: "splash", path: "/splash"),
  login(title: "login", path: "/login"),
  error(title: "error", path: "/error");

  final String title;
  final String path;

  const RouterPage({required this.title, required this.path, });
}

// Wrapper around GoRouter for injecting dependencies such as auth services,
// allowing for dynamic redirecting based on auth status managed in dedicated
// state providers
class AppRouter {
  late final AppDelegate appDelegate;

  GoRouter get router => _goRouter;

  AppRouter({required this.appDelegate});

  late final GoRouter _goRouter = GoRouter(
    refreshListenable: appDelegate,
    initialLocation: RouterPage.dashboard.path,
    routes: <GoRoute>[
      GoRoute(
        path: RouterPage.dashboard.path,
        name: RouterPage.dashboard.title,
        builder: (context, state) => DashboardScreen(),
      ),
      GoRoute(
        path: RouterPage.splash.path,
        name: RouterPage.splash.title,
        builder: (context, state) => const SplashPage(),
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
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: (state) {
      final loginLocation = state.namedLocation(RouterPage.login.title);
      final splashLocation = state.namedLocation(RouterPage.splash.title);
      final dashboardLocation = state.namedLocation(RouterPage.dashboard.title);

      final isLoggedIn = appDelegate.isLoggedIn;
      final isInitialized = appDelegate.isInitialized;

      final isOnLoginPage = state.subloc == loginLocation;
      final isOnSplashPage = state.subloc == splashLocation;

      if (!isInitialized) {
        // Redirect to splash screen while app is pending initialization
        return (isOnSplashPage) ? null : splashLocation;
      } else {
        if (!isLoggedIn) {
          return (isOnLoginPage) ? null : loginLocation;
        } else {
          return (isOnLoginPage) ? dashboardLocation : null;
        }
      }
      return null;
    },
  );
}