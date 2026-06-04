import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/deferred_link_service.dart';

void main() {
  group('deferredInviteDeepLinkHost', () {
    test('uses default StudyU host when no deep link scheme is configured', () {
      expect(deferredInviteDeepLinkHost(null), 'app.studyu.health');
    });

    test('uses configured deep link host', () {
      expect(
        deferredInviteDeepLinkHost('https://example.studyu.health'),
        'example.studyu.health',
      );
    });
  });
}
