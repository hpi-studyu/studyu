import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:uuid/uuid.dart';


class InviteCodeFormViewModel extends FormViewModel {
  InviteCodeFormViewModel({
    required this.study,
    required this.inviteCodeRepository
  }) {
    regenerateCode(); // initialize randomly
  }

  final Study study;
  final IInviteCodeRepository inviteCodeRepository;

  @override
  String get title => "New Access Code".hardcoded;

  // - Form Fields

  late final codeControl = FormControl<String>(
    validators: [Validators.required],
    asyncValidators: [_uniqueInviteCode],
    asyncValidatorsDebounceTime: 200,
  );
  String get code => codeControl.value!;
  final codeControlValidationMessages = (control) => {
    ValidationMessage.required: 'The access code must not be empty'.hardcoded,
    'inviteCodeAlreadyUsed': 'This access code is already in use'.hardcoded,
  };

  final isPreconfiguredScheduleControl = FormControl<bool>(value: false);
  bool get isPreconfiguredSchedule => isPreconfiguredScheduleControl.value!;

  final preconfiguredScheduleTypeControl = FormControl<StudyScheduleType>(
      value: StudyScheduleType.abab);
  StudyScheduleType? get preconfiguredScheduleType =>
      preconfiguredScheduleTypeControl.value;

  final interventionAControl = FormControl<String>();
  String? get interventionA => interventionAControl.value;

  final interventionBControl = FormControl<String>();
  String? get interventionB => interventionBControl.value;

  List<FormControlOption<String>> get interventionControlOptions =>
      study.interventions.map((intervention) =>
          FormControlOption(intervention.id, intervention.name!)).toList();

  List<FormControlOption<StudyScheduleType>> get preconfiguredScheduleTypeOptions => [
    FormControlOption(StudyScheduleType.abab, StudyScheduleType.abab.string)
  ];

  List<String>? get preconfiguredSchedule =>
      (interventionA != null && interventionB != null)
          ? [interventionA!, interventionB!] : null;

  @override
  late final form = FormGroup({
    'code': codeControl,
    'isPreconfiguredSchedule': isPreconfiguredScheduleControl,
    'interventionA': interventionAControl,
    'interventionB': interventionBControl,
  });

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
    final uniqueComponent = Uuid().v4().substring(0,8);
    final code = "$uniqueComponent-$studyComponent";
    return code;
  }

  StudyInvite toDomainModel() {
    return StudyInvite(code, study.id,
        preselectedInterventionIds: preconfiguredSchedule);
  }

  void fromDomainModel(StudyInvite invite) {
    throw UnimplementedError();
  }

  @override
  Future<StudyInvite> save() {
    return inviteCodeRepository.saveStudyInvite(toDomainModel());
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final inviteCodeFormViewModelProvider = Provider.autoDispose
    .family<InviteCodeFormViewModel, StudyID>((ref, studyId) {
      // Reactively bind to & obtain [StudyController]'s current study
      final study = ref.watch(
          studyControllerProvider(studyId).select((state) => state.study));
      return InviteCodeFormViewModel(
        study: study.value!,
        inviteCodeRepository: ref.watch(inviteCodeRepositoryProvider),
      );
});

