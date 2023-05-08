// ignore_for_file: avoid_classes_with_only_static_members

import 'package:logging/logging.dart';
import 'package:sentry/sentry.dart';

class Analytics {
  static Logger logger = Logger('');

  static Future<void> captureEvent(
    SentryEvent event, {
    required StackTrace stackTrace,
  }) async {
    await Sentry.captureEvent(
      event,
      stackTrace: stackTrace,
    );
  }

  static Future<void> captureException(
    dynamic exception, {
    required StackTrace stackTrace,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }

  static void addBreadcrumb({required String message, required String category}) {
    Sentry.addBreadcrumb(Breadcrumb(message: message, category: category));
  }
}
