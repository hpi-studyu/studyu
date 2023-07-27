import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_wrapper.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';

abstract class ScreenerQuestionFormViewModel<D extends QuestionFormData> extends QuestionFormViewModel<D> with ScreenerQuestionFormViewModelMixin {
  static ScreenerQuestionFormViewModel<FD> concrete<FD extends QuestionFormData>({
    FD? formData,
    delegate,
    validationSet = StudyFormValidationSet.draft,
    titles
  }) {
    QuestionFormViewModel ret;
    switch (FD) {
      case BoolQuestionFormData:
        ret = ScreenerBoolQuestionFormViewModel(
          formData: formData as BoolQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
      case ScaleQuestionFormData:
        ret = ScreenerScaleQuestionFormViewModel(
          formData: formData as ScaleQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
      case ChoiceQuestionFormData:
      default:
        ret = ScreenerChoiceQuestionFormViewModel(
          formData: formData as ChoiceQuestionFormData?,
          delegate: delegate,
          validationSet: validationSet,
          titles: titles);
        break;
    }
    return ret as ScreenerQuestionFormViewModel<FD>;
  }
}

class ScreenerBoolQuestionFormViewModel = BoolQuestionFormViewModel with ScreenerQuestionFormViewModelMixin;
class ScreenerChoiceQuestionFormViewModel = ChoiceQuestionFormViewModel with ScreenerQuestionFormViewModelMixin;
class ScreenerScaleQuestionFormViewModel = ScaleQuestionFormViewModel with ScreenerQuestionFormViewModelMixin;

class ScreenerQuestionFormViewModelWrapper extends QuestionFormViewModelWrapper<ScreenerQuestionFormViewModel> {
  ScreenerQuestionFormViewModelWrapper(super.model);

  @override
  onQuestionTypeChanged(SurveyQuestionType? newType) {
    model.form.markAsDirty();
    switch (newType) {
      case SurveyQuestionType.bool:
        model = ScreenerBoolQuestionFormViewModel(
            delegate: model.delegate, validationSet: model.validationSet
          ) as ScreenerQuestionFormViewModel<QuestionFormData>;
        break;
      case SurveyQuestionType.scale:
        model = ScreenerScaleQuestionFormViewModel(
            delegate: model.delegate, validationSet: model.validationSet
          ) as ScreenerQuestionFormViewModel<QuestionFormData>;
        break;
      case SurveyQuestionType.choice:
        model = ScreenerChoiceQuestionFormViewModel(
            delegate: model.delegate, validationSet: model.validationSet
          ) as ScreenerQuestionFormViewModel<QuestionFormData>;
        break;
      default:
        throw UnimplementedError();
    }
  }
}
