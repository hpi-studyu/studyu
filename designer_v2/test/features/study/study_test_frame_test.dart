@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
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

  test('live edits update the URL used to open the preview', () {
    final controller =
        WebController('https://app.example/?studyid=study', 'study')
          ..generateUrl(
            route: 'intervention',
            extra: 'intervention-1',
            cmd: 'reset',
            data: '{"title":"old"}',
          );

    controller.updateData('{"title":"edited"}');

    final parameters = Uri.parse(controller.previewSrc).queryParameters;
    expect(parameters['route'], 'intervention');
    expect(parameters['extra'], 'intervention-1');
    expect(parameters['cmd'], 'reset');
    expect(parameters['data'], '{"title":"edited"}');
  });
}
