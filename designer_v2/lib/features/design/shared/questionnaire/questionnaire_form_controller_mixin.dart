import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_wrapper.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

mixin WithQuestionnaireControls<D, Q extends QuestionFormViewModelWrapper> on FormViewModel<D>
    implements IFormViewModelDelegate<Q>, IProviderArgsResolver<Q, QuestionFormRouteArgs> {
  late final FormArray questionsArray = FormArray([]);
  late final modelCollection = FormViewModelCollection<Q, QuestionFormData>([], questionsArray);

  List<Q> get modelWrappers => modelCollection.formViewModels;

  late final questionnaireControls = {
    'questions': questionsArray,
  };

  void setQuestionnaireControlsFrom(QuestionnaireFormData data) {
    if (data.questionsData != null) {
      final viewModels = data.questionsData!.map((data) => provideModelWrapper(data)).toList();
      modelCollection.reset(viewModels);
    }
  }

  QuestionnaireFormData buildQuestionnaireFormData() {
    return QuestionnaireFormData(
      questionsData: modelCollection.formData,
    );
  }

  /// May be overridden in subclasses to customize the title
  Map<FormMode, LocalizedStringResolver> get questionTitles => {};

  @override
  void read([D? formData]) {
    modelCollection.read();
    super.read(formData);
  }

  // - IFormViewModelDelegate<QuestionFormViewModel>

  /// Flag indicating whether the [FormViewModel] implementing this mixin
  /// should be saved when one of the managed [QuestionFormViewModel]s is saved
  bool propagateOnSave = false;

  @override
  void onCancel(Q modelWrapper, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  Future onSave(Q modelWrapper, FormMode prevFormMode) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      modelCollection.commit(modelWrapper);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    if (propagateOnSave) {
      await super.save();
    }
  }

  // IProviderArgsResolver

  @override
  Q provide(QuestionFormRouteArgs args) {
    if (args.questionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final modelWrapper = provideModelWrapper<ChoiceQuestionFormData>(null);
      modelCollection.stage(modelWrapper);
      return modelWrapper;
    }

    final viewModel = modelCollection.findWhere((vm) => vm.model.questionId == args.questionId);
    if (viewModel == null) {
      throw QuestionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  Q provideModelWrapper<FD extends QuestionFormData>(FD? formData) {
    // we need to specify <QuestionFormViewModel> here so it doesn't
    // automatically use the concrete type
    return QuestionFormViewModelWrapper<QuestionFormViewModel>(QuestionFormViewModel.concrete<FD>(
      formData: formData,
      delegate: this,
      validationSet: validationSet,
      titles: questionTitles.isNotEmpty ? questionTitles : null,
    )) as Q;
  }
}
