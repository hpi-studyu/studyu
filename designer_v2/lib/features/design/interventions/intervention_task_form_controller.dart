import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:uuid/uuid.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class InterventionTaskFormViewModel
    extends ManagedFormViewModel<InterventionTaskFormData>
    with WithScheduleControls {
  InterventionTaskFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  // - Form fields

  final FormControl<TaskID> taskIdControl = FormControl(
      validators: [Validators.required], value: const Uuid().v4()); // hidden
  final FormControl<String> taskTitleControl =
      FormControl(validators: [Validators.required]);
  final FormControl<String> taskDescriptionControl = FormControl();
  final FormControl<bool> markAsCompletedControl =
      FormControl(); // not yet supported

  TaskID get taskId => taskIdControl.value!;

  @override
  FormValidationConfigSet get validationConfig => {
    StudyFormValidationSet.draft: [], // TODO
    StudyFormValidationSet.publish: [], // TODO
    StudyFormValidationSet.test: [], // TODO
  };

  @override
  late final FormGroup form = FormGroup({
    'taskId': taskIdControl, // hidden
    'taskTitle': taskTitleControl,
    'taskDescription': taskDescriptionControl,
    'markAsCompleted':
        markAsCompletedControl, // TODO: figure out how to disable this
    ...scheduleFormControls
  });

  @override
  void setControlsFrom(InterventionTaskFormData data) {
    taskIdControl.value = data.taskId;
    taskTitleControl.value = data.taskTitle;
    taskDescriptionControl.value = data.taskDescription;
    setScheduleControlsFrom(data);
  }

  @override
  InterventionTaskFormData buildFormData() {
    return InterventionTaskFormData(
      taskId: taskId,
      taskTitle: taskTitleControl.value!, // required
      taskDescription: taskDescriptionControl.value,
      isTimeLocked: isTimeRestrictedControl.value!, // required
      timeLockStart: restrictedTimeStartControl.value?.toStudyUTimeOfDay(),
      timeLockEnd: restrictedTimeEndControl.value?.toStudyUTimeOfDay(),
      hasReminder: hasReminderControl.value!, // required
      reminderTime: reminderTimeControl.value?.toStudyUTimeOfDay(),
    );
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: "New Treatment".hardcoded,
        FormMode.edit: "Edit Treatment".hardcoded,
        FormMode.readonly: "View Treatment".hardcoded,
      };

  // - ManagedFormViewModel

  @override
  InterventionTaskFormViewModel createDuplicate() {
    return InterventionTaskFormViewModel(
        delegate: delegate,
        formData: formData?.copy(),
        validationSet: validationSet);
  }
}
