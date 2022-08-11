import 'dart:async';

typedef VoidCallback = void Function();

abstract class ExecutionLimiter {
  ExecutionLimiter({this.milliseconds = 300});
  final int milliseconds;
  Timer? _timer;

  void dispose() {
    _timer?.cancel();
  }
}

class Debouncer extends ExecutionLimiter {
  Debouncer({super.milliseconds = 300, this.leading = true});

  /// If there is no active debounce, the callback is called immediately
  /// Subsequent calls within the debounce interval are debounced as usual
  final bool leading;

  call(VoidCallback callback) {
    final duration = Duration(milliseconds: milliseconds);

    if (!(_timer?.isActive ?? false) && leading) {
      callback();
      // start a dummy timer so that subsequent calls fall through to the
      // else-branch
      _timer = Timer(duration, () => {});
    } else {
      _timer?.cancel();
      _timer = Timer(duration, callback);
    }
  }
}

class Throttler extends ExecutionLimiter {
  Throttler({super.milliseconds = 300});

  call(VoidCallback callback) {
    if (_timer?.isActive ?? false) return;
    _timer?.cancel();
    callback();
    _timer = Timer(Duration(milliseconds: milliseconds), () {});
  }
}
