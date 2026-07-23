import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/widgets/deep_link_onboarding_widgets.dart';
import 'package:studyu_core/env.dart';
import 'package:supabase/supabase.dart';

void main() {
  setUpAll(() {
    setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  group('buildAppLaunchLink', () {
    test('uses public study universal link for public study links', () {
      expect(
        buildAppLaunchLink(studyId: 'test-study-id'),
        'https://app.studyu.health/study/test-study-id',
      );
    });
  });

  group('buildAppLaunchLink with prod-like env', () {
    setUp(() {
      appDeepLinkScheme = 'https://app.studyu.health';
    });
    tearDown(() {
      appDeepLinkScheme = null;
    });

    test('invite link uses custom scheme studyu-app:// for app launch', () {
      expect(buildAppLaunchLink(inviteCode: '123'), 'studyu-app://invite/123');
    });

    test('public study link still uses HTTPS universal link', () {
      expect(
        buildAppLaunchLink(studyId: 'test-study-id'),
        'https://app.studyu.health/study/test-study-id',
      );
    });
  });
}
