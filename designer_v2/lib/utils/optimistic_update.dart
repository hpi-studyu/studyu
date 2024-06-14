import 'package:studyu_designer_v2/utils/performance.dart';

typedef VoidCallback = void Function();
typedef VoidFutureCallback = Future<void> Function();
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// Helper class to encapsulate optimistic operations that are rolled back
/// on error
class OptimisticUpdate {
  OptimisticUpdate({
    required this.applyOptimistic,
    required this.apply,
    required this.rollback,
    this.onUpdate,
    this.onError,
    this.rethrowErrors = false,
    this.runOptimistically = true,
    this.completeFutureOptimistically = true,
  });

  final VoidCallback applyOptimistic;
  final VoidFutureCallback apply;
  final VoidCallback rollback;

  /// Callback that is always called after [apply] and [rollback]
  final VoidCallback? onUpdate;

  final ErrorCallback? onError;

  final bool rethrowErrors;

  /// Flag indicating whether the optimistic update should be run
  final bool runOptimistically;

  final bool completeFutureOptimistically;

  Future<void> execute() async {
    if (runOptimistically) {
      applyOptimistic();
    }
    _runUpdateHandlerIfAny();
    try {
      if (completeFutureOptimistically) {
        runAsync(apply);
      } else {
        await apply();
      }
      _runUpdateHandlerIfAny();
    } catch (e, stackTrace) {
      onError?.call(e, stackTrace);
      rollback();
      _runUpdateHandlerIfAny();
      if (rethrowErrors) {
        rethrow;
      }
    }
  }

  void _runUpdateHandlerIfAny() {
    onUpdate?.call();
  }
}
