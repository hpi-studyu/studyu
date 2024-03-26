import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

/// Interface for implementation by any resources that want to bind themselves
/// to the application lifecycle
abstract class IAppDelegate {
  Future<bool> onAppStart();
}

typedef _DelegateCallback = Future<bool> Function(IAppDelegate delegate);

/// Main controller that's bound to the top-level application widget's state
class AppController extends StateNotifier<AppControllerState> {
  /// List of listeners for app lifecycle events registered via Riverpod
  final List<IAppDelegate> appDelegates;

  /// A dummy [Future] used for setting a lower bound on app initialization
  /// (so that the splash screen is shown during this time)
  late final _delayedFuture = Future.delayed(const Duration(milliseconds: Config.minSplashTime), () => true);

  AppController({required this.appDelegates}) : super(const AppControllerState());

  get isInitialized => state.status == AppStatus.initialized;

  Future<bool> onAppStart() async {
    // Forward onAppStart to all registered delegates so that they can
    // e.g. read some data from local storage for initialization
    final result = await _callDelegates((delegate) => delegate.onAppStart(), withMinDelay: true);
    state = const AppControllerState(status: AppStatus.initialized);
    return result;
  }

  /// Executes the given callback for all registered delegates concurrently
  Future<bool> _callDelegates(_DelegateCallback function, {withMinDelay = false}) async {
    final List<Future<bool>> delegateFutures = [];
    // Collect all delegated futures
    for (final delegate in appDelegates) {
      final future = function(delegate);
      delegateFutures.add(future);
    }
    // Optionally add a delay
    if (withMinDelay) {
      delegateFutures.add(_delayedFuture);
    }
    // Wait for all futures to be completed while executing concurrently
    List<bool> results = await Future.wait(delegateFutures);
    return !results.contains(false);
  }
}

final appControllerProvider = StateNotifierProvider<AppController, AppControllerState>((ref) {
  final appController = AppController(appDelegates: [
    /// Register [IAppDelegate]s here for invocation of app lifecycle methods
    ref.watch(authRepositoryProvider),
  ]);
  appController.addListener((state) {
    print("appController.state updated");
  });
  ref.onDispose(() {
    print("appControllerProvider.DISPOSE");
  });
  print("appControllerProvider");
  return appController;
});
