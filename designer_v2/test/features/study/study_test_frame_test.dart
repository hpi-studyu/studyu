@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

void main() {
  test('form rebuilds keep the loaded intervention preview route', () {
    final initial = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-1',
        ),
      ),
    );
    final editedTask = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionTaskFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-1',
          taskId: 'task-2',
        ),
      ),
    );
    final otherIntervention = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-2',
        ),
      ),
    );

    expect(editedTask, initial);
    expect(otherIntervention, isNot(initial));
  });
}
