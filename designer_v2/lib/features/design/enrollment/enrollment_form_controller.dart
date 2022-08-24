import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class EnrollmentFormViewModel extends FormViewModel<EnrollmentFormData>
    with WithQuestionnaireControls
    implements
        IFormViewModelDelegate<QuestionFormViewModel>,
        IListActionProvider<QuestionFormViewModel>,
        IProviderArgsResolver<QuestionFormViewModel, QuestionFormRouteArgs> {
  EnrollmentFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet.draft,
  }) {
    // automatically save when a managed child view model is saved
    propagateOnSave = true;
  }

  final Study study;
  final GoRouter router;

  // - Form fields

  final FormControl<Participation> enrollmentTypeControl = FormControl();

  List<FormControlOption<Participation>> get enrollmentTypeControlOptions =>
      Participation.values
          .map((v) =>
              FormControlOption(v, v.string, description: v.designDescription))
          .toList();

  @override
  FormValidationConfigSet get validationConfig => {
        StudyFormValidationSet.draft: [], // TODO
        StudyFormValidationSet.publish: [], // TODO
        StudyFormValidationSet.test: [], // TODO
      };

  @override
  late final FormGroup form = FormGroup({
    'enrollmentType': enrollmentTypeControl,
    ...questionnaireControls,
  });

  @override
  void setControlsFrom(EnrollmentFormData data) {
    enrollmentTypeControl.value = data.enrollmentType;
    setQuestionnaireControlsFrom(data.questionnaireFormData);
  }

  @override
  EnrollmentFormData buildFormData() {
    return EnrollmentFormData(
      enrollmentType: enrollmentTypeControl.value!,
      questionnaireFormData: buildQuestionnaireFormData(),
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // no title

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availableActions(model,
        onEdit: onSelectItem, isReadOnly: isReadonly);
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availablePopupActions(model,
        isReadOnly: isReadonly);
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availableInlineActions(model,
        isReadOnly: isReadonly);
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(QuestionFormViewModel item) {
    // TODO: open sidesheet programmatically
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
  }

  // TODO: get rid of this after refactoring sidesheet to route (inject from router)

  ScreenerQuestionFormRouteArgs buildNewFormRouteArgs() {
    return ScreenerQuestionFormRouteArgs(
      studyId: study.id,
      questionId: Config.newModelId,
    );
  }

  ScreenerQuestionFormRouteArgs buildFormRouteArgs(
      QuestionFormViewModel model) {
    return ScreenerQuestionFormRouteArgs(
      studyId: study.id,
      questionId: model.questionId,
    );
  }

  testScreener() {
    router.dispatch(RoutingIntents.studyTest(study.id));
  }
}
