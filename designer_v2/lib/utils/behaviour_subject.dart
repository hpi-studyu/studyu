import 'dart:async';

import 'package:rxdart/subjects.dart';

class SuppressedBehaviorSubject<T> {
  SuppressedBehaviorSubject(this.subject);

  final BehaviorSubject<T> subject;
  bool didSuppressInitialEvent = false;

  late final StreamController<T> _controller = _buildDerivedController();

  StreamController<T> _buildDerivedController() {
    final StreamController<T> controller = StreamController.broadcast();
    final subjectSubscription = subject.listen((event) {
      if (!didSuppressInitialEvent) {
        didSuppressInitialEvent = true;
        return;
      }
      if (!subject.isClosed) {
        controller.add(event);
      }
    });
    controller.onCancel = () {
      subjectSubscription.cancel();
      controller.close();
    };
    return controller;
  }

  void close() {
    _controller.close();
  }
}
