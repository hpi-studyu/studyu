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
  });

  final VoidCallback applyOptimistic;
  final VoidFutureCallback apply;
  final VoidCallback rollback;

  /// Callback that is always called after [apply] and [rollback]
  final VoidCallback? onUpdate;

  final ErrorCallback? onError;

  final bool rethrowErrors;

  Future<void> execute() async {
    applyOptimistic();
    _runUpdateHandlerIfAny();
    try {
      await apply();
      _runUpdateHandlerIfAny();
    } catch(e, stackTrace) {
      if (onError != null) {
        onError!(e, stackTrace);
      }
      rollback();
      _runUpdateHandlerIfAny();
      if (rethrowErrors) {
        rethrow;
      }
    }
  }

  void _runUpdateHandlerIfAny() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }
}
