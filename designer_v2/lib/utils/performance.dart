import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Prevents jank from lazy-loading system-specific emoji fonts
/// See https://github.com/flutter/flutter/issues/42586
void prefetchEmojiFont() {
  final ParagraphBuilder pb = ParagraphBuilder(
    ParagraphStyle(
      locale: WidgetsBinding.instance.platformDispatcher.locale,
    ),
  );
  pb.addText('\ud83d\ude01'); // smiley face emoji
  pb.build().layout(const ParagraphConstraints(width: 100));
}

Future<T> runInBackground<T>(T Function() func) async {
  final p = ReceivePort();

  await Isolate.spawn(
    (SendPort sendPort) {
      final result = func();
      if (result != null) {
        Isolate.exit(sendPort, result);
      }
    },
    p.sendPort,
  );

  return await p.first as T;
}

/// Immediately queues up the [computation] in the event loop
Future<T> runAsync<T>(FutureOr<T> Function()? computation) {
  return Future.delayed(Duration.zero, computation);
}
