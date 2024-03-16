// ignore_for_file: avoid_classes_with_only_static_members

import 'package:logger/logger.dart';


class StudyULogger {
  static Logger logger = Logger();

  static void trace(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void debug(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void info(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void error(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void fatal(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.f(message, time: time, error: error, stackTrace: stackTrace);
  }
}
