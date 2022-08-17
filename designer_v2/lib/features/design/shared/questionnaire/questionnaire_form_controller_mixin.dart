import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

mixin WithQuestionnaireControls<T> on FormViewModel<T>
    implements
        IFormViewModelDelegate<QuestionFormViewModel>,
        IProviderArgsResolver<QuestionFormViewModel, QuestionFormRouteArgs> {

  late final FormArray questionsArray = FormArray(
      [], validators: questionsArrayValidators);
  late final questionFormViewModels =
      FormViewModelCollection<QuestionFormViewModel, QuestionFormData>(
          [], questionsArray);

  List<QuestionFormViewModel> get questionModels =>
      questionFormViewModels.formViewModels;

  late final questionnaireControls = {
    'questions': questionsArray,
  };

  List<ValidatorFunction> get questionsArrayValidators => [];

  void setQuestionnaireControlsFrom(QuestionnaireFormData data) {
    if (data.questionsData != null) {
      final viewModels = data.questionsData!
          .map((data) => QuestionFormViewModel(formData: data, delegate: this))
          .toList();
      questionFormViewModels.reset(viewModels);
    }
  }

  QuestionnaireFormData buildQuestionnaireFormData() {
    return QuestionnaireFormData(
      questionsData: questionFormViewModels.formData,
    );
  }

  @override
  void read([T? formData]) {
    questionFormViewModels.read();
    super.read(formData);
  }

  // - IFormViewModelDelegate<QuestionFormViewModel>

  /// Flag indicating whether the [FormViewModel] implementing this mixin
  /// should be saved when one of the managed [QuestionFormViewModel]s is saved
  bool propagateOnSave = false;

  @override
  void onCancel(QuestionFormViewModel formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  void onSave(QuestionFormViewModel formViewModel, FormMode prevFormMode) {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      questionFormViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    if (propagateOnSave) {
      super.save();
    }
  }

  // IProviderArgsResolver

  @override
  QuestionFormViewModel provide(QuestionFormRouteArgs args) {
    if (args.questionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = QuestionFormViewModel(formData: null, delegate: this);
      questionFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = questionFormViewModels
        .findWhere((vm) => vm.questionId == args.questionId);
    if (viewModel == null) {
      throw QuestionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }
}
