import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';
import 'package:uuid/uuid.dart';


class MeasurementSurveyFormViewModel extends FormViewModel<MeasurementSurveyFormData>
    implements IFormViewModelDelegate<SurveyQuestionFormViewModel>,
        IListActionProvider<ModelActionType, SurveyQuestionFormData>,
        IProviderArgsResolver<SurveyQuestionFormViewModel, SurveyQuestionFormRouteArgs> {

  MeasurementSurveyFormViewModel({
    required this.study,
    super.delegate,
    super.formData,
  });

  final Study study;
  final surveyQuestionFormViewModels = FormViewModelCollection<
      SurveyQuestionFormViewModel, SurveyQuestionFormData>([]);

  List<SurveyQuestionFormData> get surveyQuestionsData =>
      surveyQuestionFormViewModels.formData;

  // - Form fields

  final FormControl<MeasurementID> measurementIdControl = FormControl(
      validators: [Validators.required], disabled: true); // hidden
  final FormControl<String> surveyTitleControl = FormControl(
      validators: [Validators.minLength(3)]);
  final FormControl<String> surveyIntroTextControl = FormControl();
  final FormControl<String> surveyOutroTextControl = FormControl();
  FormArray get surveyQuestionsArray => surveyQuestionFormViewModels.formArray;

  MeasurementID get measurementId => measurementIdControl.value!;

  @override
  late final FormGroup form = FormGroup({
    'measurementId': measurementIdControl, // hidden
    'surveyTitle': surveyTitleControl,
    'surveyIntroText': surveyIntroTextControl,
    'surveyOutroText': surveyOutroTextControl,
    'surveyQuestions': surveyQuestionsArray,
  });

  @override
  void initControls() {
    measurementIdControl.value = const Uuid().v4();
    surveyTitleControl.value = MeasurementSurveyFormData.kDefaultTitle;
  }

  @override
  void setControlsFrom(MeasurementSurveyFormData data) {
    measurementIdControl.value = data.measurementId;
    surveyTitleControl.value = data.title;
    surveyIntroTextControl.value = data.introText ?? '';
    surveyOutroTextControl.value = data.outroText ?? '';

    if (data.surveyQuestionsData != null) {
      final viewModels = data.surveyQuestionsData!.map(
              (data) => SurveyQuestionFormViewModel(
                  study: study, formData: data, delegate: this
              )).toList();
      surveyQuestionFormViewModels.reset(viewModels);
    }
  }

  @override
  MeasurementSurveyFormData buildFormData() {
    return MeasurementSurveyFormData(
      measurementId: measurementId, // required hidden
      title: surveyTitleControl.value!, // required
      introText: surveyIntroTextControl.value,
      outroText: surveyOutroTextControl.value,
      surveyQuestionsData: surveyQuestionsData,
    );
  }

  String get breadcrumbsTitle {
    final components = [
      study.title, formData?.title ?? MeasurementSurveyFormData.kDefaultTitle
    ];
    return components.join(kPathSeparator);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: breadcrumbsTitle,
    FormMode.edit: breadcrumbsTitle,
  };

  // - IListActionProvider

  @override
  List<ModelAction<ModelActionType>> availableActions(SurveyQuestionFormData model) {
    // TODO: set & propagate FormMode.readonly at root FormViewModel (if needed)
    final isNotReadonly = formMode != FormMode.readonly;

    final actions = [
      ModelAction(
        type: ModelActionType.edit,
        label: ModelActionType.edit.string,
        onExecute: () => onSelectItem(model),
        isAvailable: isNotReadonly,
      ),
      ModelAction(
        type: ModelActionType.duplicate,
        label: ModelActionType.duplicate.string,
        onExecute: () {
          // Add a new view model with copied data to the form
          final formViewModel = SurveyQuestionFormViewModel(
              study: study, formData: model.copy(), delegate: this,
          );
          surveyQuestionFormViewModels.add(formViewModel);
        },
        isAvailable: isNotReadonly,
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        isDestructive: true,
        onExecute: () {
          surveyQuestionFormViewModels.removeWhere(
                  (vm) => vm.formData!.questionId == model.questionId);
        },
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction<ModelActionType>> availablePopupActions(
      SurveyQuestionFormData model) {
    return availableActions(model).where(
            (action) => action.type != ModelActionType.edit).toList();
  }

  List<ModelAction<ModelActionType>> availableInlineActions(
      SurveyQuestionFormData model) {
    return availableActions(model).where(
            (action) => action.type == ModelActionType.edit).toList();
  }

  @override
  void onSelectItem(SurveyQuestionFormData item) {
    // TODO: open sidesheet programmatically
    print("select item");
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
    print("new item");
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(SurveyQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  void onSave(SurveyQuestionFormViewModel formViewModel, FormMode prevFormMode) {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      surveyQuestionFormViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
  }

  // - IProviderArgsResolver

  @override
  SurveyQuestionFormViewModel provide(SurveyQuestionFormRouteArgs args) {
    if (args.questionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = SurveyQuestionFormViewModel(
          study: study, formData: null, delegate: this);
      surveyQuestionFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = surveyQuestionFormViewModels.findWhere(
            (vm) => vm.questionId == args.questionId);
    if (viewModel == null) {
      throw SurveyQuestionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // TODO: get rid of this after refactoring sidesheet to route (inject from router)

  SurveyQuestionFormRouteArgs buildNewFormRouteArgs() {
    return SurveyQuestionFormRouteArgs(
      studyId: study.id,
      measurementId: measurementId,
      questionId: Config.newModelId,
    );
  }

  SurveyQuestionFormRouteArgs buildFormRouteArgs(SurveyQuestionFormData data) {
    final args = SurveyQuestionFormRouteArgs(
      studyId: study.id,
      measurementId: measurementId,
      questionId: data.questionId,
    );
    return args;
  }
}
