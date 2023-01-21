import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
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
  final defaultLocation = RouterConf.studies.path;

  return GoRouter(
    refreshListenable: CombinedStreamNotifier([
      // Any stream registered here will trigger the router's redirect logic
      appController.stream,                          // initialization events
      authRepository.watchAuthStateChanges()  // authentication events
    ]),
    initialLocation: defaultLocation,
    routes: RouterConf.topLevelRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (_, state) {
      final loginLocation = RouterConf.login.path;
      final signupLocation = RouterConf.signup.path;
      final splashLocation = RouterConf.splash.path;
      final passwordRecoveryLocation = RouterConf.passwordRecovery.path;
      final isOnDefaultPage = state.subloc == defaultLocation;
      final isOnLoginPage = state.subloc == loginLocation;
      final isOnSignupPage = state.subloc == signupLocation;
      final isOnSplashPage = state.subloc == splashLocation;
      final isOnPasswordRecoveryPage = state.subloc == passwordRecoveryLocation;
      final isOnPublicPage = RouterConf.topLevelPublicRoutes.any((element) => element.path == state.subloc);

      // Read most recent app state on re-evaluation (see refreshListenable)
      final isLoggedIn = authRepository.isLoggedIn;
      var allowPasswordReset = authRepository.allowPasswordReset;
      final isInitialized = appController.isInitialized;

      // Carry original location through the redirect flow so that we can
      // redirect the user to where they came from after initialization
      final String? from;
      if (state.queryParams.containsKey('from')) {
        from = state.queryParams['from'];
      } else {
        if (!(isOnDefaultPage | isOnSplashPage)) {
          from = state.subloc;
        } else {
          from = null;
        }
      }
      // Helper to generate routes carrying the 'from' param (if any)
      namedLocForwarded(String name) {
        final Map<String,String> qParams = {};
        if (from != null && from != '/') { // if (from != null && from != '/' && from != defaultLocation) {
          qParams["from"] = from;
        }
        return state.namedLocation(name, queryParams: qParams);
      }

      if (!isInitialized) {
        // Redirect to splash screen while app is pending initialization
        return (isOnSplashPage)
            ? null : namedLocForwarded(RouterConf.splash.name!);
      }

      /*print("***NEW ROUTER***");
      print("subloc: " + state.subloc);
      print("isOnPublicPage: " + isOnPublicPage.toString());
      if (from != null) {
        print("from: $from");
      } else {
        print("from: null");
      }*/

      // Handle password recovery
      if (allowPasswordReset) {
        if (isOnPasswordRecoveryPage) {
          authRepository.allowPasswordReset = false;
          return null;
        } else {
          return namedLocForwarded(RouterConf.passwordRecovery.name!);
        }
      }

      if (!isLoggedIn) {
        if (from != null) {  /*&& !isOnSplashPage*/ /*&& state.subloc != '/'*/
          // Only allow access to public pages...
          if (!isOnSplashPage && isOnPublicPage) {
            return null;
            // ... else send user to their origin location
          } else if (from != state.subloc) {
            return from;
          }
        }
        // Redirect to login page as default
        return (isOnLoginPage) ? null : namedLocForwarded(RouterConf.login.name!);

      } else {
        // If the user is authenticated, forward to where
        // they were going initially...
        if (from != null && from != state.subloc) {
          return from;
        }
        // ...or send them to the default location if they just authenticated
        // and weren't going anywhere
        if (isOnLoginPage || isOnSplashPage || isOnSignupPage) {
          return defaultLocation;
        }
      }
      // don't redirect in all other cases
      return null;
    },
    debugLogDiagnostics: kDebugMode,
  );
});

