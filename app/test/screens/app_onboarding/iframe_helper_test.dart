import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';

void main() {
  test('preview messages are skipped when no iframe parent exists', () {
    final helper = IFrameHelper();

    expect(() => helper.postPreviewStatus(status: 'loaded'), returnsNormally);
    expect(helper.postRouteFinished, returnsNormally);
  });
}
