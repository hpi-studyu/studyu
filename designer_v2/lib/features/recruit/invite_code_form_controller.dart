import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:uuid/uuid.dart';

class InviteCodeFormViewModel extends FormViewModel<StudyInvite> {
  InviteCodeFormViewModel({
    required this.study,
    required this.inviteCodeRepository
  }) : super();

  final Study study;
  final IInviteCodeRepository inviteCodeRepository;

  @override
  Map<FormMode,String> get titles => {
    FormMode.create: "New Access Code".hardcoded,
    FormMode.readonly: "Access Code".hardcoded,
  };

  // - Form Fields

  late final codeControl = FormControl<String>(
    validators: [Validators.required, Validators.minLength(8), Validators.maxLength(24)],
    asyncValidators: [_uniqueInviteCode],
    asyncValidatorsDebounceTime: 200,
    touched: true,
  );
  final codeControlValidationMessages = {
    ValidationMessage.required: (error) => 'The code must not be empty'.hardcoded,
    ValidationMessage.minLength: (error) => 'The code must have at least 8 characters'.hardcoded,
    ValidationMessage.maxLength: (error) => 'The code must have at most 24 characters'.hardcoded,
    'inviteCodeAlreadyUsed': (error) => 'This code is already in use'.hardcoded,
  };

  final isPreconfiguredScheduleControl = FormControl<bool>(value: false);
  final preconfiguredScheduleTypeControl = FormControl<StudyScheduleType>(
      value: StudyScheduleType.abab);
  final interventionAControl = FormControl<String>();
  final interventionBControl = FormControl<String>();

  List<FormControlOption<String>> get interventionControlOptions =>
      study.interventions.map((intervention) =>
          FormControlOption(intervention.id, intervention.name!)).toList();

  List<FormControlOption<StudyScheduleType>> get preconfiguredScheduleTypeOptions => [
    FormControlOption(StudyScheduleType.abab, StudyScheduleType.abab.string)
  ];

  bool get isPreconfiguredSchedule => isPreconfiguredScheduleControl.value!;

  List<String>? get preconfiguredSchedule => (isPreconfiguredSchedule &&
      interventionAControl.value != null && interventionBControl.value != null)
          ? [interventionAControl.value!, interventionBControl.value!] : null;

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

  Future<Map<String, dynamic>?> _uniqueInviteCode(AbstractControl control) async {
    final code = control.value;
    final isCodeAlreadyUsed = await inviteCodeRepository.isCodeAlreadyUsed(code);
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
    final studyComponent = study.id.substring(0,8);
    final uniqueComponent = const Uuid().v4().substring(0,8);
    final code = "$uniqueComponent-$studyComponent";
    return code;
  }

  @override
  StudyInvite buildFormData() {
    return StudyInvite(
      codeControl.value!,
      study.id,
      preselectedInterventionIds: preconfiguredSchedule
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
  Future<StudyInvite> save({updateState = true}) {
    return inviteCodeRepository.save(buildFormData())
        .then((wrapped) => wrapped!.model);
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final inviteCodeFormViewModelProvider = Provider.autoDispose
  .family<InviteCodeFormViewModel, StudyID>((ref, studyId) {
    print("inviteCodeFormViewModelProvider(${studyId}");
    // Reactively bind to & obtain [StudyController]'s current study
    final study = ref.watch(
        studyControllerProvider(studyId).select((state) => state.study));
    final inviteCodeRepository = ref.watch(
        inviteCodeRepositoryProvider(studyId));

    return InviteCodeFormViewModel(
      study: study.value!, inviteCodeRepository: inviteCodeRepository,
    );
});
