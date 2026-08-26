import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';

void main() {
  test('preview messages are skipped when no iframe parent exists', () {
    final helper = IFrameHelper();

    expect(() => helper.postPreviewStatus(status: 'loaded'), returnsNormally);
    expect(helper.postRouteFinished, returnsNormally);
  });

  group('deriveDesignerOrigin', () {
    test('prefers the embedding parent origin over the compiled fallback', () {
      expect(
        deriveDesignerOrigin(
          'https://designer--pr909-preview.firebaseapp.com/',
          'https://designer.dev.studyu.health',
        ),
        'https://designer--pr909-preview.firebaseapp.com',
      );
    });

    test('falls back to the compiled designer url', () {
      expect(
        deriveDesignerOrigin(null, 'https://designer.dev.studyu.health'),
        'https://designer.dev.studyu.health',
      );
      expect(
        deriveDesignerOrigin('', 'https://designer.dev.studyu.health/'),
        'https://designer.dev.studyu.health',
      );
      expect(deriveDesignerOrigin('not-a-url', null), isNull);
      expect(deriveDesignerOrigin(null, null), isNull);
    });
  });
}
