import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/pages/login_page.dart';
import 'package:studyu_designer_v2/pages/study_dashboard_screen.dart';

import '../pages/my_app.dart';
import 'user.dart';

// List of all pages in the application
// To create a new page, 1) add an entry to the enum and 2) add the page to the AppRouter class
enum RouterPage {
  dashboard(title: "dashboard", path: "/home"),
  //splash(title: "splash", path: "/splash"),
  login(title: "login", path: "/login");
  //error(title: "error", path: "/error");

  final String title;
  final String path;

  const RouterPage({required this.title, required this.path, });
}

//late final AppDelegate appDelegate;

/// Caches and Exposes a [GoRouter]
final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    //refreshListenable: appDelegate,
    refreshListenable: router,
    initialLocation: RouterPage.dashboard.path,
    debugLogDiagnostics: true, // For demo purposes
    //errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: router._redirectLogic, // All the logic is centralized here
    routes: router._routes, // All the routes can be found there
  );
});

/// My favorite approach: ofc there's room for improvement, but it works fine.
/// What I like about this is that `RouterNotifier` centralizes all the logic.
/// The reason we use `ChangeNotifier` is because it's a `Listenable` object,
/// as required by `GoRouter`'s `refreshListenable` parameter.
/// Unluckily, it is not possible to use a `StateNotifier` here, since it's
/// not a `Listenable`. Recall that `StateNotifier` is to be preferred over
/// `ChangeNotifier`, see https://riverpod.dev/docs/concepts/providers/#different-types-of-providers
/// There are other approaches to solve this, and they can
/// be found in the `/others` folder.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  /// This implementation exploits `ref.listen()` to add a simple callback that
  /// calls `notifyListeners()` whenever there's change onto a desider provider.
  RouterNotifier(this._ref) {
    _ref.listen<User?>(
      userProvider,
      // In our case, we're interested in the log in / log out events.
      (_, __) => notifyListeners(), // Obviously more logic can be added here
    );
  }

  /// IMPORTANT: conceptually, we want to use `ref.read` to read providers, here.
  /// GoRouter is already aware of state changes through `refreshListenable`
  /// We don't want to trigger a rebuild of the surrounding provider.
  String? _redirectLogic(GoRouterState state) {

    final loginLocation = state.namedLocation(RouterPage.login.title);
    //final splashLocation = state.namedLocation(RouterPage.splash.title);
    final dashboardLocation = state.namedLocation(RouterPage.dashboard.title);

    //final isLoggedIn = appDelegate.isLoggedIn;
    //@TODO use app_service
    final user = _ref.read(userProvider);
    final isLoggedIn = user != null;

    //final isInitialized = appDelegate.isInitialized;
    const isInitialized = true;

    final isOnLoginPage = state.subloc == loginLocation;
    //final isOnSplashPage = state.subloc == splashLocation;

    if (!isInitialized) {
      // Redirect to splash screen while app is pending initialization
      //return (isOnSplashPage) ? null : splashLocation;
    } else {
      if (!isLoggedIn) {
        print("not logged in");
        return (isOnLoginPage) ? null : loginLocation;
      } else {
        print("logged in");
        return (isOnLoginPage) ? dashboardLocation : null;
      }
    }
    return null;
  }

  List<GoRoute> get _routes => [
    /*GoRoute(
      name: "home",
      path: '/',
      builder: (context, _) => const HomePage(),
    ),*/
    GoRoute(
      path: RouterPage.dashboard.path,
      name: RouterPage.dashboard.title,
      // TODO SWITCH TO DASHBOARD
      //builder: (context, state) => const StudyDashboardScreen(),
      builder: (context, _) => const StudyDashboardScreen(),
      //builder: (context, _) => const HomePage(),
    ),
    GoRoute(
      name: "login",
      path: '/login',
      builder: (context, _) => const LoginPage(),
    ),
  ];
}
