import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_data.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/features/study/study_test_app_routes.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class EnrollmentFormViewModel extends FormViewModel<EnrollmentFormData>
    with
        WithQuestionnaireControls<EnrollmentFormData,
            ScreenerQuestionFormViewModel>
    implements
        IFormViewModelDelegate<ScreenerQuestionFormViewModel>,
        IListActionProvider<ScreenerQuestionFormViewModel>,
        IProviderArgsResolver<ScreenerQuestionFormViewModel,
            QuestionFormRouteArgs> {
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

  late final consentItemDelegate = EnrollmentFormConsentItemDelegate(
    formViewModels: consentItemFormViewModels,
    owner: this,
    validationSet: super.validationSet,
  );

  // - Form fields

  final FormControl<Participation> enrollmentTypeControl = FormControl();
  final FormControl<bool> lockEnrollmentTypeControl = FormControl();

  List<FormControlOption<Participation>> get enrollmentTypeControlOptions =>
      Participation.values
          .map(
            (v) => FormControlOption(
              v,
              v.string,
              description: v.designDescription,
            ),
          )
          .toList();

  late final FormArray consentItemArray = FormArray([]);
  late final FormViewModelCollection<ConsentItemFormViewModel,
          ConsentItemFormData> consentItemFormViewModels =
      FormViewModelCollection([], consentItemArray);

  List<ConsentItemFormViewModel> get consentItemModels =>
      consentItemFormViewModels.formViewModels;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: [], // TODO
        StudyFormValidationSet.publish: [], // TODO
        StudyFormValidationSet.test: [], // TODO
      };

  @override
  late final FormGroup form = FormGroup({
    'enrollmentType': enrollmentTypeControl,
    'lockEnrollmentType': lockEnrollmentTypeControl,
    'consentItems': consentItemArray,
    ...questionnaireControls,
  });

  @override
  void setControlsFrom(EnrollmentFormData data) {
    enrollmentTypeControl.value = data.enrollmentType;
    lockEnrollmentTypeControl.value = data.lockEnrollmentType;

    if (!study.isTemplate) {
      lockEnrollmentTypeControl.markAsDisabled();
    }

    if (study.isSubStudy && study.templateConfiguration?.lockEnrollmentType == true) {
      enrollmentTypeControl.markAsDisabled();
    }

    setQuestionnaireControlsFrom(data.questionnaireFormData);

    if (data.consentItemsFormData != null) {
      final viewModels = data.consentItemsFormData!
          .map(
            (data) => ConsentItemFormViewModel(
              formData: data,
              delegate: consentItemDelegate,
              validationSet: validationSet,
            ),
          )
          .toList();
      consentItemFormViewModels.reset(viewModels);
    }
  }

  @override
  EnrollmentFormData buildFormData() {
    return EnrollmentFormData(
      enrollmentType: enrollmentTypeControl.value!,
      lockEnrollmentType: lockEnrollmentTypeControl.value ?? false,
      questionnaireFormData: buildQuestionnaireFormData(),
      consentItemsFormData: consentItemFormViewModels.formData,
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // no title

  @override
  void read([EnrollmentFormData? formData]) {
    questionFormViewModels.read();
    consentItemFormViewModels.read();
    super.read(formData);
  }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ScreenerQuestionFormViewModel model) {
    final actions = questionFormViewModels.availableActions(
      model,
      onEdit: onSelectItem,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(ScreenerQuestionFormViewModel model) {
    final actions = questionFormViewModels.availablePopupActions(
      model,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(
    ScreenerQuestionFormViewModel model,
  ) {
    final actions = questionFormViewModels.availableInlineActions(
      model,
      isReadOnly: isReadonly,
    );
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

  ScreenerQuestionFormRouteArgs buildNewScreenerQuestionFormRouteArgs() {
    return ScreenerQuestionFormRouteArgs(
      studyCreationArgs: StudyCreationArgs.fromStudy(study),
      questionId: Config.newModelId,
    );
  }

  ScreenerQuestionFormRouteArgs buildScreenerQuestionFormRouteArgs(
    QuestionFormViewModel model,
  ) {
    return ScreenerQuestionFormRouteArgs(
      studyCreationArgs: StudyCreationArgs.fromStudy(study),
      questionId: model.questionId,
    );
  }

  ConsentItemFormRouteArgs buildNewConsentItemFormRouteArgs() {
    return ConsentItemFormRouteArgs(
      studyCreationArgs: StudyCreationArgs.fromStudy(study),
      consentId: Config.newModelId,
    );
  }

  ConsentItemFormRouteArgs buildConsentItemFormRouteArgs(
    ConsentItemFormViewModel model,
  ) {
    return ConsentItemFormRouteArgs(
      studyCreationArgs: StudyCreationArgs.fromStudy(study),
      consentId: model.consentId,
    );
  }

  void testScreener() {
    router.dispatch(
      RoutingIntents.studyTest(
        study.id,
        appRoute: TestAppRoutes.eligibility,
      ),
    );
  }

  void testConsent() {
    router.dispatch(
      RoutingIntents.studyTest(study.id, appRoute: TestAppRoutes.consent),
    );
  }

  bool get canTestScreener =>
      !questionsArray.disabled && (questionsArray.value?.isNotEmpty ?? false);
  bool get canTestConsent =>
      !consentItemArray.disabled &&
      (consentItemArray.value?.isNotEmpty ?? false);

  @override
  Map<FormMode, LocalizedStringResolver> get questionTitles => {
        FormMode.create: () => tr.form_screener_question_create,
        FormMode.edit: () => tr.form_screener_question_edit,
        FormMode.readonly: () => tr.form_screener_question_readonly,
      };

  @override
  ScreenerQuestionFormViewModel provideQuestionFormViewModel(
    QuestionFormData? formData,
  ) {
    return ScreenerQuestionFormViewModel(
      formData: formData,
      delegate: this,
      validationSet: validationSet,
      titles: questionTitles.isNotEmpty ? questionTitles : null,
    );
  }
}

class EnrollmentFormConsentItemDelegate
    implements
        IFormViewModelDelegate<ConsentItemFormViewModel>,
        IListActionProvider<ConsentItemFormViewModel>,
        IProviderArgsResolver<ConsentItemFormViewModel,
            ConsentItemFormRouteArgs> {
  EnrollmentFormConsentItemDelegate({
    required this.formViewModels,
    required this.owner,
    this.validationSet,
    this.propagateOnSave = true,
  });

  final FormViewModelCollection<ConsentItemFormViewModel, ConsentItemFormData>
      formViewModels;
  final EnrollmentFormViewModel owner;
  final bool propagateOnSave;
  final FormValidationSetEnum? validationSet;

  @override
  void onCancel(ConsentItemFormViewModel formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  Future onSave(
    ConsentItemFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      formViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    if (propagateOnSave) {
      await owner.save();
    }
  }

  @override
  ConsentItemFormViewModel provide(ConsentItemFormRouteArgs args) {
    if (args.consentId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = ConsentItemFormViewModel(
        delegate: this,
        validationSet: validationSet,
      );
      formViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel =
        formViewModels.findWhere((vm) => vm.consentId == args.consentId);
    if (viewModel == null) {
      throw ConsentItemNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ConsentItemFormViewModel model) {
    final actions = formViewModels.availablePopupActions(
      model,
      isReadOnly: owner.isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
  }

  @override
  void onSelectItem(ConsentItemFormViewModel item) {
    // TODO: open sidesheet programmatically
  }
}
