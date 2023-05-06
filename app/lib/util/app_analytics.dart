import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class AppAnalytics {
  final BuildContext context;
  AppState state;
  StudySubject subject;

  AppAnalytics(this.context) {
    state = context.read<AppState>();
    subject = state.activeSubject;
  }

  Future<void> initBasic() async {
    Sentry.configureScope(
      (scope) async {
        final basicContext = {
          'selectedStudyObjectId': getActiveSubjectId(),
          'isPreview': state.isPreview,
          'sharedPrefsEmail': await getFakeUserEmail(),
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
}
