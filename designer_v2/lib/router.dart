import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_page.dart';
import 'package:studyu_designer_v2/pages/error_page.dart';
import 'package:studyu_designer_v2/pages/login_page.dart';
import 'package:studyu_designer_v2/pages/my_app.dart';
import 'package:studyu_designer_v2/pages/splash_page.dart';
import 'package:studyu_designer_v2/services/app_service.dart';
import 'package:studyu_designer_v2/services/auth_store.dart';

// List of all pages in the application
// To create a new page, 1) add an entry to the enum and 2) add the page to the AppRouter class
enum RouterPage {
  dashboard(title: "dashboard", path: "/"),
  splash(title: "splash", path: "/splash"),
  login(title: "login", path: "/login"),
  error(title: "error", path: "/error");

  final String title;
  final String path;

  const RouterPage({required this.title, required this.path});
}

/// Caches and Exposes a [GoRouter]
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable: ref.watch(appDelegateProvider),
    initialLocation: RouterPage.dashboard.path,
    debugLogDiagnostics: true,
    // For demo purposes todo remove later
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: ref.watch(routerNotifierProvider)._redirectLogic,
    // All the logic is centralized here
    routes: ref
        .watch(routerNotifierProvider)
        ._routes, // All the routes can be found there
  );
});

final routerNotifierProvider = Provider((ref) => RouterNotifier());

class RouterNotifier extends ChangeNotifier {
  late final AppDelegate delegate;

  /// IMPORTANT: conceptually, we want to use `ref.read` to read providers, here.
  /// GoRouter is already aware of state changes through `refreshListenable`
  /// We don't want to trigger a rebuild of the surrounding provider.
  String? _redirectLogic(GoRouterState state) {
    final loginLocation = state.namedLocation(RouterPage.login.title);
    final splashLocation = state.namedLocation(RouterPage.splash.title);
    final dashboardLocation = state.namedLocation(RouterPage.dashboard.title);

    final isLoggedIn = AuthStore().isLoggedIn;
    final isInitialized = delegate.isInitialized;

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
  }

  List<GoRoute> get _routes => [
        GoRoute(
          path: RouterPage.dashboard.path,
          name: RouterPage.dashboard.title,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouterPage.splash.path,
          name: RouterPage.splash.title,
          builder: (context, state) => SplashPage(delegate),
        ),
        GoRoute(
          path: RouterPage.login.path,
          name: RouterPage.login.title,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RouterPage.error.path,
          name: RouterPage.error.title,
          builder: (context, state) => ErrorPage(error: state.extra.toString()),
        ),
      ];
}
