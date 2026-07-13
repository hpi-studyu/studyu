import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockApi extends Mock implements StudyUApi {}

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockStudyRepository extends Mock implements IStudyRepository {}

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
    env.setEnv(
      'https://example.supabase.co',
      'key',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'key'),
      envAppDeepLinkScheme: 'https://app.example.com',
    );
  });

  test('invite actions use clear labels and keep delete last', () {
    final authRepository = _MockAuthRepository();
    final studyRepository = _MockStudyRepository();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ref = container.read(Provider<Ref>((ref) => ref));
    final user = User(
      id: 'owner',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime(2026).toIso8601String(),
    );
    final study = Study.withId('owner');

    when(authRepository.currentUser).thenReturn(user);
    when(studyRepository.get('study')).thenReturn(WrappedModel(study));

    final repository = InviteCodeRepository(
      studyId: 'study',
      apiClient: _MockApi(),
      authRepository: authRepository,
      studyRepository: studyRepository,
      ref: ref,
    );

    final actions = repository.availableActions(StudyInvite('CODE', 'study'));

    expect(actions.map((action) => action.type), [
      ModelActionType.clipboard,
      ModelActionType.share,
      ModelActionType.copyLink,
      ModelActionType.qrCodeShow,
      null,
      ModelActionType.delete,
    ]);
    expect(
      actions
          .where((action) => !action.isSeparator)
          .map((action) => action.label),
      [
        'Copy invite code',
        'Share invite link',
        'Copy invite link',
        'View QR code',
        'Delete invite code',
      ],
    );
  });
}
