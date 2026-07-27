import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';

class _FakeInviteCodeRepository implements InviteCodeFormRepository {
  _FakeInviteCodeRepository({Set<String>? usedCodes})
    : _usedCodes = usedCodes ?? <String>{};

  final Set<String> _usedCodes;
  final List<String> lookedUpCodes = <String>[];

  @override
  Future<bool> isCodeAlreadyUsed(String code) async {
    lookedUpCodes.add(code);
    return _usedCodes.contains(code);
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InviteCodeFormViewModel', () {
    late Study study;
    late _FakeInviteCodeRepository inviteCodeRepository;

    setUp(() {
      study = Study('study-id', 'owner-id');
      inviteCodeRepository = _FakeInviteCodeRepository();
    });

    Future<void> validateCodeControl(InviteCodeFormViewModel controller) async {
      controller.codeControl.markAsTouched();
      controller.codeControl.updateValueAndValidity();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    test(
      'keeps the existing invite code valid when opening an invite',
      () async {
        final existingInvite = StudyInvite('existing-code', study.id);

        final controller = InviteCodeFormViewModel(
          study: study,
          inviteCodeRepository: inviteCodeRepository,
          formData: existingInvite,
        )..read(existingInvite);

        await validateCodeControl(controller);

        expect(
          controller.codeControl.hasError(ValidationMessage.required),
          isFalse,
        );
        expect(
          controller.codeControl.hasError('inviteCodeAlreadyUsed'),
          isFalse,
        );
        expect(inviteCodeRepository.lookedUpCodes, isEmpty);
      },
    );

    test('still rejects a different existing invite code', () async {
      final existingInvite = StudyInvite('existing-code', study.id);
      inviteCodeRepository = _FakeInviteCodeRepository(
        usedCodes: {'another-code'},
      );

      final controller = InviteCodeFormViewModel(
        study: study,
        inviteCodeRepository: inviteCodeRepository,
        formData: existingInvite,
      )..read(existingInvite);

      controller.codeControl.value = 'another-code';
      await validateCodeControl(controller);

      expect(controller.codeControl.hasError('inviteCodeAlreadyUsed'), isTrue);
      expect(inviteCodeRepository.lookedUpCodes, contains('another-code'));
    });
  });
}
