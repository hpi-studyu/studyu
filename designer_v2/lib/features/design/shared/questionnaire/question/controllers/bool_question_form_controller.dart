import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class BoolQuestionFormViewModel extends QuestionFormViewModel<BoolQuestionFormData> {
  BoolQuestionFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
    titles,
  }) : _titleResources = titles;

  final Map<FormMode, LocalizedStringResolver>? _titleResources;

  List<AbstractControl<String>> get options =>
      BoolQuestionFormData.kResponseOptions.keys.map((e) => FormControl(value: e, disabled: true)).toList();

  late final FormArray<String> _responseOptionsArray = FormArray(options);

  @override
  SurveyQuestionType get questionType => SurveyQuestionType.bool;

  @override
  Map<FormMode, LocalizedStringResolver>? get titleResources => _titleResources;

  @override
  FormArray<String> get responseOptionsArray => _responseOptionsArray;
  
  @override
  FormGroup get controls => FormGroup({
      'boolOptionsArray': _responseOptionsArray,
  });

  @override void setControlsFrom(BoolQuestionFormData data) {}

  @override
  BoolQuestionFormViewModel createDuplicate() {
    return BoolQuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
      titles: _titleResources,
    );
  }
}
