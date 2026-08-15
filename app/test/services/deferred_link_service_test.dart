import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/deferred_link_service.dart';

void main() {
  group('deferredInviteDeepLinkHost', () {
    test('uses configured deep link host', () {
      expect(
        deferredInviteDeepLinkHost('https://example.studyu.health'),
        'example.studyu.health',
      );
    });
  });

  group('parseAndroidDeferredLink', () {
    test('parses invite links from new Android referrer key', () {
      final link = parseAndroidDeferredLink(
        inviteCode: null,
        studyId: null,
        referrer: 'utm_source=landing&invite=invite-123',
      );

      expect(link?.inviteCode, 'invite-123');
      expect(link?.studyId, isNull);
    });

    test('parses study links from new Android referrer key', () {
      final link = parseAndroidDeferredLink(
        inviteCode: null,
        studyId: null,
        referrer: 'utm_source=landing&study=study-123',
      );

      expect(link?.studyId, 'study-123');
      expect(link?.inviteCode, isNull);
    });

    test(
      'preserves invite precedence when a referrer contains invite and study',
      () {
        final link = parseAndroidDeferredLink(
          inviteCode: null,
          studyId: null,
          referrer: 'utm_source=landing&study=study-123&invite=invite-123',
        );

        expect(link?.inviteCode, 'invite-123');
        expect(link?.studyId, isNull);
      },
    );
  });

  group('parseIosDeferredLinkPath', () {
    test('keeps invite links routable from deferred universal link paths', () {
      final link = parseIosDeferredLinkPath(
        'https://app.studyu.health/invite/invite-123',
      );

      expect(link?.inviteCode, 'invite-123');
      expect(link?.studyId, isNull);
    });

    test('parses public study links from deferred universal link paths', () {
      final link = parseIosDeferredLinkPath(
        'https://app.studyu.health/study/study-123',
      );

      expect(link?.studyId, 'study-123');
      expect(link?.inviteCode, isNull);
    });
  });
}
