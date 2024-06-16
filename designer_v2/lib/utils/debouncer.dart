import 'dart:async';

import 'package:async/async.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

abstract class ExecutionLimiter {
  ExecutionLimiter({this.milliseconds = 300});
  final int milliseconds;
  static Timer? _timer;

  void dispose() {
    _timer?.cancel();
  }
}

class Debouncer extends ExecutionLimiter {
  Debouncer({
    super.milliseconds = 300,
    this.leading = true,
    this.cancelUncompleted = true,
  });

  /// If there is no active debounce, the callback is called immediately
  /// Subsequent calls within the debounce interval are debounced as usual
  final bool leading;

  /// If another operation is debounced before the future returned by the
  /// previous operation has completed, cancel the previous future & prevent
  /// it from executing entirely (if set to true)
  final bool cancelUncompleted;

  CancelableOperation? _uncompletedFutureOperation;

  void call({VoidCallback? callback, FutureFactory? futureBuilder}) {
    if ((callback == null && futureBuilder == null) ||
        (callback != null && futureBuilder != null)) {
      throw Exception(
        "Must call Debouncer with either callback or futureBuilder",
      );
    }

    // Wrap the given callback so we can work with a future-based interface
    futureBuilder ??= () => runAsync(callback);

    void startFutureOperation() {
      print("startFutureOperation");
      _uncompletedFutureOperation = CancelableOperation.fromFuture(
        futureBuilder!().then((_) => _uncompletedFutureOperation = null),
        onCancel: () => print("future cancelled"),
      );
    }

    final timerDuration = Duration(milliseconds: milliseconds);

    if (leading && !(ExecutionLimiter._timer?.isActive ?? false)) {
      startFutureOperation();
      // start a dummy timer so that subsequent calls fall through to the
      // else-branch
      ExecutionLimiter._timer = Timer(timerDuration, () => {});
    } else {
      _uncompletedFutureOperation?.cancel();
      ExecutionLimiter._timer?.cancel();
      ExecutionLimiter._timer = Timer(timerDuration, startFutureOperation);
    }
  }
}

class Throttler extends ExecutionLimiter {
  Throttler({super.milliseconds = 300});

  void call(VoidCallback callback) {
    if (ExecutionLimiter._timer?.isActive ?? false) return;
    ExecutionLimiter._timer?.cancel();
    callback();
    ExecutionLimiter._timer =
        Timer(Duration(milliseconds: milliseconds), () {});
  }
}
