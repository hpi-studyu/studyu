import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:uuid/uuid.dart';

class FormControlOption<T> {
  final T value;
  final String label;

  FormControlOption(this.value, this.label);
}

class StudyInviteCodeForm {
  static final String kTitle = "New Access Code".hardcoded;

  StudyInviteCodeForm(this.study) {
    regenerateCode(); // initialize randomly
  }

  final Study study;

  void regenerateCode() {
    codeControl.value = _generateCode();
  }

  String _generateCode() {
    final studyComponent = study.id.substring(0,8);
    final uniqueComponent = Uuid().v4().substring(0,8);
    final code = "$uniqueComponent-$studyComponent";
    return code;
  }

  bool get isValid => form.valid; // TODO: extract to parent

  // - Form Fields

  final codeControl = FormControl<String>(validators: [Validators.required]);
  String get code => codeControl.value!; // TODO: async validator to ensure uniqueness

  final isPreconfiguredScheduleControl = FormControl<bool>(value: false);
  bool get isPreconfiguredSchedule => isPreconfiguredScheduleControl.value!;

  final interventionAControl = FormControl<String>();
  String get interventionA => interventionAControl.value!;

  final interventionBControl = FormControl<String>();
  String get interventionB => interventionBControl.value!;

  List<FormControlOption<String>> get interventionControlOptions =>
      study.interventions.map((intervention) =>
          FormControlOption(intervention.id, intervention.name!)).toList();

  List<String>? get preconfiguredSchedule =>
      isPreconfiguredSchedule ? [interventionA, interventionB] : null;

  late final form = FormGroup({
    'code': codeControl,
    'isPreconfiguredSchedule': isPreconfiguredScheduleControl,
    'interventionA': interventionAControl,
    'interventionB': interventionBControl,
  });

  StudyInvite toDomainModel() {
    return StudyInvite(code, study.id,
        preselectedInterventionIds: preconfiguredSchedule);
  }

  void fromDomainModel(StudyInvite invite) {
    throw UnimplementedError();
  }
}