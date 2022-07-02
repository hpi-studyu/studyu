import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/utils/combined_stream_notifier.dart';

import 'router_config.dart';

// TODO: Update docs here
/// To create a new page:
/// 1) add an entry to the [RouterPage] enum
/// 2) add the page widget to the [routes] list

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
      final splashLocation = state.namedLocation(RouterConfig.splash.name!);
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
        return (isOnSplashPage)
            ? null : namedLocForwarded(RouterConfig.splash.name!);
      }
      if (!isLoggedIn) {
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
        if (isOnLoginPage || isOnSplashPage) {
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

