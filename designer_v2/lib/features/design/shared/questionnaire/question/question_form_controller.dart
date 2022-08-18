import 'dart:async';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

class QuestionFormViewModel extends ManagedFormViewModel<QuestionFormData>
    implements IListActionProvider<AbstractControl<String>> {
  static const defaultQuestionType = SurveyQuestionType.choice;

  QuestionFormViewModel(
      {super.formData,
      super.delegate,
      super.validationSet = StudyFormValidationSet.draft}) {
    // Keep the form in sync with the selected question type
    _updateFormControls(questionType);
    _questionTypeChanges =
        questionTypeControl.valueChanges.listen(_updateFormControls);
  }

  late final StreamSubscription _questionTypeChanges;

  // - Form fields (any question type)

  final FormControl<QuestionID> questionIdControl = FormControl(
      validators: [Validators.required], value: const Uuid().v4()); // hidden
  final FormControl<SurveyQuestionType> questionTypeControl = FormControl(
      validators: [Validators.required], value: defaultQuestionType);
  final FormControl<String> questionTextControl =
      FormControl(validators: [Validators.required]);
  final FormControl<String> questionInfoTextControl = FormControl();

  QuestionID get questionId => questionIdControl.value!;
  SurveyQuestionType get questionType => questionTypeControl.value!;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) =>
              FormControlOption(questionType, questionType.string))
          .toList();

  late final Map<String, AbstractControl> _questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
  };

  // - Form fields (question type-specific)

  final FormControl<bool> isMultipleChoiceControl =
      FormControl(validators: [Validators.required], value: false);
  final FormArray<String> answerOptionsArray = FormArray([], validators: [
    CountWhereValidator<String>((value) => value != null && value.isNotEmpty,
            minCount: 2, maxCount: 10)
        .validate
  ]);
  List<AbstractControl<String>> get answerOptionsControls =>
      answerOptionsArray.controls;

  late final Map<SurveyQuestionType, FormGroup> _controlsByQuestionType = {
    SurveyQuestionType.bool: FormGroup({}),
    SurveyQuestionType.choice: FormGroup({
      'isMultipleChoice': isMultipleChoiceControl,
      'answerOptionsArray': answerOptionsArray,
    }),
    SurveyQuestionType.scale: FormGroup({
      // TODO implement SurveyQuestionType.scale controls
    }),
  };

  @override
  FormValidationConfigSet get validationConfig => {
    StudyFormValidationSet.draft: [], // TODO
    StudyFormValidationSet.publish: [], // TODO
    StudyFormValidationSet.test: [], // TODO
  };

  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  @override
  late final FormGroup form = FormGroup({
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
  });

  /// Dynamically updates the [form] based on the given [questionType]
  void _updateFormControls(SurveyQuestionType? questionType) {
    final subtypeFormControls = _controlsByQuestionType[questionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!_questionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    form.updateValueAndValidity();
  }

  @override
  void setControlsFrom(QuestionFormData data) {
    // Shared controls
    questionIdControl.value = data.questionId;
    questionTextControl.value = data.questionText;
    questionTypeControl.value = data.questionType;
    questionInfoTextControl.value = data.questionInfoText ?? '';

    // Type-specific controls
    switch (data.questionType) {
      case SurveyQuestionType.bool:
        break;
      case SurveyQuestionType.choice:
        data = data as ChoiceQuestionFormData;
        isMultipleChoiceControl.value = data.isMultipleChoice;
        // Unfortunately needed because of how [FormArray.updateValue] is implemented
        // Note: `formArray.value = []` does not remove any controls!
        answerOptionsArray.clear();
        answerOptionsArray.value =
            data.answerOptions.map((option) => option.label).toList();
        break;
      case SurveyQuestionType.scale:
        break;
    }
  }

  @override
  QuestionFormData buildFormData() {
    switch (questionType) {
      case SurveyQuestionType.bool:
        return BoolQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
        );
      case SurveyQuestionType.choice:
        return ChoiceQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          isMultipleChoice: isMultipleChoiceControl.value!, // required
          answerOptions: answerOptionsArray.value! // required
              .where((optionStr) => optionStr != null && optionStr.isNotEmpty)
              .map((optionStr) =>
                  FormControlOption<String>(optionStr!.asId(), optionStr))
              .toList(),
        );
      case SurveyQuestionType.scale:
        return ScaleQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
        );
    }
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: "New Question".hardcoded,
        FormMode.edit: "Edit Question".hardcoded,
        FormMode.readonly: "View Question".hardcoded,
      };

  @override
  List<ModelAction> availableActions(AbstractControl<String> model) {
    final isNotReadonly = formMode != FormMode.readonly;

    final actions = [
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        isDestructive: true,
        onExecute: () {
          final controlIdx = answerOptionsArray.controls.indexOf(model);
          answerOptionsArray.removeAt(controlIdx);
        },
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    answerOptionsArray.add(FormControl<String>());
  }

  @override
  void onSelectItem(AbstractControl<String> item) {
    return; // no-op
  }

  @override
  QuestionFormViewModel createDuplicate() {
    return QuestionFormViewModel(
        delegate: delegate,
        formData: formData?.copy(),
        validationSet: validationSet);
  }
}
