import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

import '../constants.dart';





abstract class INavigationService extends IAppDelegate {
  void goToStudy(Study study);
  void goToNewStudy();
  void goToDashboard();
  void goToErrorPage(Exception? error);
  void dispose();
}

/// A simple wrapper around [GoRouter] that acts as the central coordinator
/// responsible for app-wide navigation.
///
/// Enables navigation logic to be cleanly decoupled so that it can be
/// maintained in controllers & tested independently.
class NavigationService implements INavigationService {
  NavigationService({required this.router});

  /// Reference to [GoRouter] injected via Riverpod
  final GoRouter router;

  @override
  void goToStudy(Study study) {
    _go(RouterConfig.studyEdit, params: {"studyId": study.id});
  }

  @override
  void goToNewStudy() {
    _go(RouterConfig.studyEdit, params: {"studyId": Config.newStudyId});
  }

  @override
  void goToDashboard() {
    _go(RouterConfig.studies);
  }

  @override
  void goToErrorPage(Exception? error) {
    _go(RouterConfig.error, extra: error);
  }

  void goTo404Page(Exception? error) {
    _go(RouterConfig.error, extra: error);
  }

  _go(GoRoute route, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
    Object? extra,
    int? delayMilliseconds,
  }) {
    navigateClosure() {
      router.goNamed(
          route.name!, params: params, queryParams: queryParams, extra: extra);
    }

    if (delayMilliseconds != null) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), navigateClosure);
    } else {
      navigateClosure();
    }
  }

  @override
  void dispose() {
    // nothing to clean up
  }

  // - IAppDelegate

  @override
  Future<bool> onAppStart() async {
    // Nothing to initialize for now
    // Initial routing flow is handled via router's redirect logic
    return true;
  }
}

final navigationServiceProvider = riverpod.Provider<INavigationService>((ref) {
  final navigationService = NavigationService(router: ref.watch(routerProvider));
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    navigationService.dispose();
  });
  return navigationService;
});
