import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';

class Analytics {
  final BuildContext context;
  AppState state;
  StudySubject subject;

  Analytics(this.context) {
    state = context.read<AppState>();
    subject = state.activeSubject;
  }

  void initBasic(String selectedStudyObjectId) {
    Sentry.configureScope(
      (scope) {
        final basicContext = {
          'selectedStudyObjectId': selectedStudyObjectId,
          'isPreview': state.isPreview,
        };
        scope.setContexts('basicState', basicContext);
      },
    );
  }

  void initAdvanced() {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: subject.userId,
      ));
      final advancedContext = {
        'subjectId': subject.id,
        'studyId': state.selectedStudy.id,
        'subject': subject.toString(),
        'selectedStudy': state.selectedStudy.toString(),
      };
      scope.setContexts('advancedState', advancedContext);
    });
  }

  captureEvent(SentryEvent event, {StackTrace stackTrace}) async {
    await Sentry.captureEvent(
      event,
      stackTrace: stackTrace,
    );
  }

  captureException(exception, {StackTrace stackTrace}) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }

  void addBreadcrumb({String message, String category}) {
    Sentry.addBreadcrumb(Breadcrumb(message: message, category: category));
  }
}
