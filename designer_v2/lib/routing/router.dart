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
/// a [RouterConfig.topLevelRoute] (most likely it should be a top-level
/// route, unless you know what you are doing with subroutes)
///
/// 2. To navigate to the new route from your code, specify one or more
/// [RoutingIntent]s in router_intent.dart. These intents correspond to
/// route changes in the app. See router_intent.dart for more details.

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final appController = ref.read(appControllerProvider.notifier);
  final defaultLocation = RouterConfig.studies.path;

  return GoRouter(
    refreshListenable: CombinedStreamNotifier([
      // Any stream registered here will trigger the router's redirect logic
      appController.stream,                   // initialization events
      authRepository.watchAuthStateChanges()  // authentication events
    ]),
    initialLocation: defaultLocation,
    routes: RouterConfig.topLevelRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (state) {
      final loginLocation = state.namedLocation(RouterConfig.login.name!);
      final signupLocation = state.namedLocation(RouterConfig.signup.name!);
      final resetPasswordLocation = state.namedLocation(RouterConfig.passwordReset.name!);
      final splashLocation = state.namedLocation(RouterConfig.splash.name!);
      final isOnDefaultPage = state.subloc == defaultLocation;
      final isOnLoginPage = state.subloc == loginLocation;
      final isOnSignupPage = state.subloc == signupLocation;
      final isOnPasswordResetPage = state.subloc == resetPasswordLocation;
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
        if (from != null && from != '/') {
          qParams["from"] = from;
        }
        return state.namedLocation(name, queryParams: qParams);
      }

      if (!isInitialized) {
        // Redirect to splash screen while app is pending initialization
        return (isOnSplashPage)
            ? null : namedLocForwarded(RouterConfig.splash.name!);
      }

      if (!isLoggedIn) {
        if (from != null && from != state.subloc) {
          return from;
        }
        // todo make this more dynamic
        if (from == RouterConfig.passwordReset.path) {
          return (isOnPasswordResetPage)
              ? null : state.namedLocation(RouterConfig.passwordReset.name!);
        }
        if (from == RouterConfig.passwordRecovery.path) {
          return (state.subloc == state.namedLocation(RouterConfig.passwordRecovery.name!))
              ? null : state.namedLocation(RouterConfig.passwordRecovery.name!);
        }
        if (from == RouterConfig.signup.path) {
          return (state.subloc == state.namedLocation(RouterConfig.signup.name!))
              ? null : state.namedLocation(RouterConfig.signup.name!);
        }

        // Redirect to login page when not logged in
        return (isOnLoginPage)
            ? null : namedLocForwarded(RouterConfig.login.name!);
      }

      if (isInitialized && isLoggedIn) {
        // If the app is initialized & user is authenticated, forward to where
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

      return null; // don't redirect in all other cases
    },
    // Turn off the # in the URLs on the web
    urlPathStrategy: UrlPathStrategy.path,
    debugLogDiagnostics: kDebugMode,
  );
});

