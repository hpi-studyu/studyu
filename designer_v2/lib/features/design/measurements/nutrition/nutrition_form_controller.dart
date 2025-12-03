import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class NutritionFormViewModel extends ManagedFormViewModel<NutritionFormData>
    with WithScheduleControls {
  NutritionFormViewModel({
    required this.study,
    super.delegate,
    super.formData,
    super.validationSet = StudyFormValidationSet.draft,
  });

  final Study study;

  // - Form fields

  final FormControl<MeasurementID> measurementIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<MeasurementID> instanceIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<String> titleControl = FormControl(
    value: NutritionFormData.kDefaultTitle,
  );
  final FormControl<String> instructionsControl = FormControl(value: '');
  final FormControl<bool> collectMealContextControl = FormControl(value: true);
  final FormControl<bool> allowRecipesControl = FormControl(value: true);
  final FormControl<int> minimumMealsRequiredControl = FormControl();
  // TODO: Add support for customMealTypes

  MeasurementID get measurementId => measurementIdControl.value!;
  MeasurementID get instanceId => instanceIdControl.value!;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [titleRequired],
    StudyFormValidationSet.publish: [titleRequired],
    StudyFormValidationSet.test: [titleRequired],
  };

  FormControlValidation get titleRequired => FormControlValidation(
    control: titleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) => tr
          .form_field_measurement_survey_title_required, // Reusing survey title required message
    },
  );

  @override
  late final FormGroup form = FormGroup({
    'measurementId': measurementIdControl, // hidden
    'title': titleControl,
    'instructions': instructionsControl,
    'collectMealContext': collectMealContextControl,
    'allowRecipes': allowRecipesControl,
    'minimumMealsRequired': minimumMealsRequiredControl,
    ...scheduleFormControls,
  });

  @override
  void setControlsFrom(NutritionFormData data) {
    instanceIdControl.value = data.instanceId;
    measurementIdControl.value = data.measurementId;
    titleControl.value = data.title;
    instructionsControl.value = data.instructions ?? '';
    collectMealContextControl.value = data.collectMealContext;
    allowRecipesControl.value = data.allowRecipes;
    minimumMealsRequiredControl.value = data.minimumMealsRequired;

    setScheduleControlsFrom(data);
  }

  @override
  NutritionFormData buildFormData() {
    final data = NutritionFormData(
      measurementId: measurementId, // required hidden
      instanceId: instanceId,
      title: titleControl.value!, // required
      instructions: instructionsControl.value,
      collectMealContext: collectMealContextControl.value ?? true,
      allowRecipes: allowRecipesControl.value ?? true,
      minimumMealsRequired: minimumMealsRequiredControl.value,
      isTimeLocked: isTimeRestrictedControl.value!, // required
      timeLockStart: restrictedTimeStartControl.value?.toStudyUTimeOfDay(),
      timeLockEnd: restrictedTimeEndControl.value?.toStudyUTimeOfDay(),
      hasReminder: hasReminderControl.value!, // required
      reminderTime: reminderTimeControl.value?.toStudyUTimeOfDay(),
    );
    return data;
  }

  String get breadcrumbsTitle {
    final components = [
      study.title,
      formData?.title ?? NutritionFormData.kDefaultTitle,
    ];
    return components.join(kPathSeparator);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: breadcrumbsTitle,
    FormMode.readonly: breadcrumbsTitle,
    FormMode.edit: breadcrumbsTitle,
  };

  // ManagedFormViewModel

  @override
  NutritionFormViewModel createDuplicate() {
    return NutritionFormViewModel(
      study: study,
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }
}
