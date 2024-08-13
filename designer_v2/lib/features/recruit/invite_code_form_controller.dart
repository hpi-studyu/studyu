import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:uuid/uuid.dart';

part 'invite_code_form_controller.g.dart';

class InviteCodeFormViewModel extends FormViewModel<StudyInvite> {
  InviteCodeFormViewModel({
    required this.study,
    required this.inviteCodeRepository,
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  final Study study;
  final IInviteCodeRepository inviteCodeRepository;

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: tr.form_code_create,
        FormMode.readonly: tr.form_code_readonly,
      };

  // - Form Fields

  final codeControl = FormControl<String>(
    asyncValidatorsDebounceTime: 200,
    touched: true,
  );
  final isPreconfiguredScheduleControl = FormControl<bool>(value: false);
  final preconfiguredScheduleTypeControl =
      FormControl<PhaseSequence>(value: PhaseSequence.alternating);
  final interventionAControl = FormControl<String>();
  final interventionBControl = FormControl<String>();

  // todo add validation for preconfigured schedule if enabled
  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: [codeValidation],
        StudyFormValidationSet.test: [codeValidation],
        StudyFormValidationSet.publish: [codeValidation],
      };

  FormControlValidation get codeRequired => FormControlValidation(
        control: codeControl,
        validators: [
          Validators.required,
        ],
        validationMessages: {
          ValidationMessage.required: (error) => tr.form_field_code_required,
        },
      );

  FormControlValidation get codeValidation => FormControlValidation(
        control: codeControl,
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.maxLength(24),
        ],
        asyncValidators: [
          Validators.delegateAsync((control) => _uniqueInviteCode(control)),
        ],
        validationMessages: {
          ValidationMessage.required: (error) => tr.form_field_code_required,
          ValidationMessage.minLength: (error) => tr.form_field_code_minlength(
                (error as Map)['requiredLength'] as int,
              ),
          ValidationMessage.maxLength: (error) => tr.form_field_code_maxlength(
                (error as Map)['requiredLength'] as int,
              ),
          'inviteCodeAlreadyUsed': (_) => tr.form_field_code_alreadyused,
        },
      );

  List<FormControlOption<String>> get interventionControlOptions =>
      study.interventions
          .map(
            (intervention) =>
                FormControlOption(intervention.id, intervention.name!),
          )
          .toList();

  List<FormControlOption<PhaseSequence>> get preconfiguredScheduleTypeOptions =>
      [
        FormControlOption(
          PhaseSequence.alternating,
          PhaseSequence.alternating.string,
        ),
      ];

  bool get isPreconfiguredSchedule => isPreconfiguredScheduleControl.value!;

  List<String>? get preconfiguredSchedule => (isPreconfiguredSchedule &&
          interventionAControl.value != null &&
          interventionBControl.value != null)
      ? [interventionAControl.value!, interventionBControl.value!]
      : null;

  @override
  late final form = FormGroup({
    'code': codeControl,
    'isPreconfiguredSchedule': isPreconfiguredScheduleControl,
    'interventionA': interventionAControl,
    'interventionB': interventionBControl,
  });

  @override
  void initControls() {
    regenerateCode(); // initialize randomly
  }

  // - Validation

  Future<Map<String, dynamic>?> _uniqueInviteCode(
    AbstractControl control,
  ) async {
    final code = control.value as String;
    final isCodeAlreadyUsed =
        await inviteCodeRepository.isCodeAlreadyUsed(code);
    final error = {'inviteCodeAlreadyUsed': true};

    if (isCodeAlreadyUsed) {
      control.markAsTouched();
      return error;
    }
    return null;
  }

  void regenerateCode() {
    codeControl.value = _generateCode();
  }

  String _generateCode() {
    final studyComponent = study.id.substring(0, 8);
    final uniqueComponent = const Uuid().v4().substring(0, 8);
    final code = "$uniqueComponent-$studyComponent";
    return code;
  }

  @override
  StudyInvite buildFormData() {
    return StudyInvite(
      codeControl.value!,
      study.id,
      preselectedInterventionIds: preconfiguredSchedule,
    );
  }

  @override
  void setControlsFrom(StudyInvite data) {
    codeControl.value = data.code;
    isPreconfiguredScheduleControl.value = data.hasPreconfiguredSchedule;
    if (data.hasPreconfiguredSchedule) {
      interventionAControl.value = data.preselectedInterventionIds![0];
      interventionBControl.value = data.preselectedInterventionIds![1];
    }
  }

  @override
  Future<StudyInvite> save({bool updateState = true}) {
    return inviteCodeRepository
        .save(buildFormData())
        .then((wrapped) => wrapped!.model);
  }
}

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
@riverpod
InviteCodeFormViewModel inviteCodeFormViewModel(
  InviteCodeFormViewModelRef ref,
  StudyID studyId,
) {
  // Reactively bind to and obtain [StudyController]'s current study
  final study = ref
      .watch(studyControllerProvider(studyId).select((state) => state.study));
  final inviteCodeRepository = ref.watch(inviteCodeRepositoryProvider(studyId));

  return InviteCodeFormViewModel(
    study: study.value!,
    inviteCodeRepository: inviteCodeRepository,
  );
}
