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
      final splashLocation = state.namedLocation(RouterConfig.splash.name!);
      final passwordRecoveryLocation = state.namedLocation(RouterConfig.passwordRecovery.name!);
      final isOnDefaultPage = state.subloc == defaultLocation;
      final isOnLoginPage = state.subloc == loginLocation;
      final isOnSignupPage = state.subloc == signupLocation;
      final isOnSplashPage = state.subloc == splashLocation;
      final isOnPasswordRecoveryLocation = state.subloc == passwordRecoveryLocation;
      final isOnStaticPage = RouterConfig.topLevelPublicRoutes.any((element) => element.path == state.subloc);

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
        // Redirect to chosen page or null if already on page
        if (from != null) {
          print("from: " + from);
        } else {
          print("from: null");
        }
        print("state.subloc: " + state.subloc);

        if (from != null && from != state.subloc) {
          if (RouterConfig.topLevelPublicRoutes.any((element) => element.path == from) || isOnSplashPage) {
            print("return from");
            return from;
          } else {
            return null;
          }
        } else {
          if (from == null) {
            if (isOnLoginPage) {
              print("isonloginpage: return null");
              return null;
            } else {
              print("!isonloginpage: return login");
              return namedLocForwarded(RouterConfig.login.name!);
            }
          }
          if (isOnStaticPage) {
            print("return null");
            return null;
          } else {
            //print("return login");
            //return namedLocForwarded(RouterConfig.login.name!);
          }
        }

        if (isOnLoginPage) {
          print("return null");
          return null;
        } else {
          print("return login page");
          return namedLocForwarded(RouterConfig.login.name!);
        }

        /*if (from != null) {
          // we are not redirected by from
          if (state.subloc != from) {
            //if (RouterConfig.topLevelStaticRoutes.any((element) => element.name == from)) {
           //   print("from is part of static routes");
            if (RouterConfig.topLevelStaticRoutes.any((element) => element.path == from) || isOnSplashPage) {
              print("return from");
              return from;
            } else {
              print("return null");
              return null;
            }
           // } else {
          //    print("route is dynamic");
            //}
          } else {
            print("from == state.subloc: return null");
            if (isOnStaticPage) {
              return null;
            }
          }
        }*/

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
      // don't redirect in all other cases
      return null;
    },
    // Turn off the # in the URLs on the web
    urlPathStrategy: UrlPathStrategy.path,
    debugLogDiagnostics: kDebugMode,
  );
});

