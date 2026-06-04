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
    test('uses studyShared universal link for public study links', () {
      expect(
        buildAppLaunchLink(studyId: 'test-study-id'),
        'https://app.studyu.health/studyShared/test-study-id',
      );
    });
  });
}
