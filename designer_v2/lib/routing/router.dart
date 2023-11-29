import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/utils/combined_stream_notifier.dart';

import 'router_config.dart';

/// How to create a new page & use it for navigation:
///
/// 1. Add the [GoRoute] in router_config.dart and register it as
/// a [RouterConf.topLevelRoute] (most likely it should be a top-level
/// route, unless you know what you are doing with subroutes)
///
/// 2. To navigate to the new route from your code, specify one or more
/// [RoutingIntent]s in router_intent.dart. These intents correspond to
/// route changes in the app. See router_intent.dart for more details.

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final appController = ref.read(appControllerProvider.notifier);
  const defaultLocation = studiesRouteName;
  late final GoRouter router;

  String? authGuard(BuildContext context, GoRouterState state) {
    final loginLocation = router.namedLocation(loginRouteName);
    final signupLocation = router.namedLocation(signupRouteName);
    final splashLocation = router.namedLocation(splashRouteName);
    final passwordRecoveryLocation = router.namedLocation(recoverPasswordRouteName);
    final isOnDefaultPage = state.matchedLocation == router.namedLocation(defaultLocation);
    final isOnLoginPage = state.matchedLocation == loginLocation;
    final isOnSignupPage = state.matchedLocation == signupLocation;
    final isOnSplashPage = state.matchedLocation == splashLocation;
    final isOnPasswordRecoveryPage = state.matchedLocation == passwordRecoveryLocation;
    final isOnPublicPage = RouterConf.publicRoutes.any((element) => element.path == state.matchedLocation);

    // Read most recent app state on re-evaluation (see refreshListenable)
    final isLoggedIn = authRepository.isLoggedIn;
    var allowPasswordReset = authRepository.allowPasswordReset;
    final isInitialized = appController.isInitialized;

    // Carry original location through the redirect flow so that we can
    // redirect the user to where they came from after initialization
    final Uri? from;
    if (state.uri.queryParameters.containsKey('from')) {
      from = Uri.tryParse(state.uri.queryParameters['from']!);
    } else {
      if (state.matchedLocation.isNotEmpty && !(isOnDefaultPage | isOnSplashPage)) {
        from = state.uri;
      } else {
        from = null;
      }
    }
    // Helper to generate routes carrying the 'from' param (if any)
    namedLocForwarded(String name) {
      final Map<String, String> qParams = {};
      if (from != null && from.toString() != '/') {
        // if (from != null && from != '/' && from != defaultLocation) {
        qParams["from"] = from.toString();
      }
      return router.namedLocation(name, queryParameters: qParams);
    }

    if (!isInitialized) {
      // Redirect to splash screen while app is pending initialization
      return (isOnSplashPage) ? null : namedLocForwarded(splashRouteName);
    }

    // Handle password recovery
    if (allowPasswordReset) {
      if (isOnPasswordRecoveryPage) {
        authRepository.allowPasswordReset = false;
        return null;
      } else {
        return namedLocForwarded(recoverPasswordRouteName);
      }
    }

    if (!isLoggedIn) {
      if (from != null) {
        /*&& !isOnSplashPage*/ /*&& state.subloc != '/'*/
        // Only allow access to public pages...
        if (!isOnSplashPage && isOnPublicPage) {
          return null;
          // ... else send user to their origin location
        } else if (from.toString() != state.uri.toString()) {
          return from.toString();
        }
      }
      // Redirect to login page as default
      return (isOnLoginPage) ? null : namedLocForwarded(loginRouteName);
    } else {
      // If the user is authenticated, forward to where they were going initially...
      if (from != null && from.toString() != state.uri.toString()) {
        return from.toString();
      }
      // ...or send them to the default location if they just authenticated and weren't going anywhere
      if (isOnLoginPage || isOnSplashPage || isOnSignupPage) {
        return '/$defaultLocation';
      }
    }
    // don't redirect in all other cases
    return null;
  }

  router = GoRouter(
    refreshListenable: CombinedStreamNotifier([
      // Any stream registered here will trigger the router's redirect logic
      appController.stream, // initialization events
      authRepository.watchAuthStateChanges() // authentication events
    ]),
    routes: RouterConf.routes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: authGuard,
    debugLogDiagnostics: kDebugMode,
  );
  RouterConf.router = router;
  return router;
});
