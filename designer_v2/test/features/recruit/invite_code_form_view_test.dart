@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:supabase/supabase.dart';

class _FakeInviteCodeRepository implements InviteCodeFormRepository {
  @override
  Future<bool> isCodeAlreadyUsed(String code) async => false;

  @override
  Future<WrappedModel<StudyInvite>?> save(
    StudyInvite invite, {
    bool runOptimistically = true,
  }) async => WrappedModel(invite);

  @override
  Future<void> delete(
    String inviteCode, {
    bool runOptimistically = true,
  }) async {}
}

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(lookupAppLocalizations(const Locale('en')));
    env.setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  testWidgets('invite link and QR code follow the code field', (tester) async {
    final viewModel = InviteCodeFormViewModel(
      study: Study('study-12345678', 'owner-id'),
      inviteCodeRepository: _FakeInviteCodeRepository(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReactiveForm(
              formGroup: viewModel.form,
              child: SingleChildScrollView(
                child: InviteCodeFormView(formViewModel: viewModel),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'New-Code');
    await tester.pump(const Duration(milliseconds: 250));

    const expectedLink = 'https://app.studyu.health/invite/new-code';
    expect(find.text(expectedLink), findsOneWidget);
    expect(
      tester.widget<QrCodePreview>(find.byType(QrCodePreview)).data,
      expectedLink,
    );
  });
}
