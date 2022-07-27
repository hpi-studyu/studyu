import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_survey_form_controller.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';


class MeasurementsFormData implements IStudyFormData {
  final List<MeasurementSurveyFormData> surveyMeasurements;

  MeasurementsFormData({required this.surveyMeasurements});

  factory MeasurementsFormData.fromStudy(Study study) {
    return MeasurementsFormData(
        surveyMeasurements: (study.observations).map(
            (observation) => MeasurementSurveyFormData.fromDomainModel(
                observation as QuestionnaireTask)).toList()
    );
  }
}

class MeasurementsFormViewModel extends FormViewModel<MeasurementsFormData>
    implements IFormViewModelDelegate<MeasurementSurveyFormViewModel>,
        IListActionProvider<ModelActionType, MeasurementSurveyFormData>,
        IProviderArgsResolver<MeasurementSurveyFormViewModel, MeasurementFormRouteArgs> {

  MeasurementsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
  }) {
    print("MeasurementsFormViewModel.new");
  }

  final Study study;
  final GoRouter router;

  final surveyMeasurementFormViewModels = FormViewModelCollection<
      MeasurementSurveyFormViewModel, MeasurementSurveyFormData>([]);

  List<MeasurementSurveyFormData> get measurementsData =>
      surveyMeasurementFormViewModels.formData;

  /*
  final List<MeasurementSurveyFormViewModel> surveyMeasurementFormViewModels = [];
  List<MeasurementSurveyFormData> get surveyMeasurementFormDataArray =>
      surveyMeasurementFormViewModels.map((vm) => vm.formData!).toList();
   */

  // - IProviderArgsResolver

  @override
  MeasurementSurveyFormViewModel provide(MeasurementFormRouteArgs args) {
    if (args.measurementId == Config.newModelId) {
      return MeasurementSurveyFormViewModel(
          study: study, formData: null, delegate: this);
    }
    // TODO handle 404 not found
    /*
    final idx = surveyMeasurementFormViewModels.indexWhere(
            (vm) => vm.formData!.measurementId == args.measurementId);
    return surveyMeasurementFormViewModels[idx];
     */
    return surveyMeasurementFormViewModels.findWhere(
            (vm) => vm.formData!.measurementId == args.measurementId)!;
  }

  // - Form fields

  /*
  FormArray get surveyMeasurementsArray => FormArray(
      surveyMeasurementFormViewModels.map((vm) => vm.form).toList());

   */

  FormArray get measurementsArray => surveyMeasurementFormViewModels.formArray;

  @override
  FormGroup get form => FormGroup({
    //'surveyMeasurements': surveyMeasurementsArray,
    'surveyMeasurements': measurementsArray,
  });

  @override
  void setFormControlValuesFrom(MeasurementsFormData data) {
    for (final surveyMeasurement in data.surveyMeasurements) {
      surveyMeasurementFormViewModels.add(
          MeasurementSurveyFormViewModel(
              study: study, formData: surveyMeasurement, delegate: this));
    }
  }

  @override
  MeasurementsFormData buildFormDataFromControls() {
    return MeasurementsFormData(
      surveyMeasurements: surveyMeasurementFormViewModels.formData,
      /*
        surveyMeasurements: surveyMeasurementFormViewModels.map(
                (vm) => vm.buildFormDataFromControls()).toList()
       */
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IListActionProvider

  @override
  List<ModelAction<ModelActionType>> availableActions(MeasurementSurveyFormData model) {
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
          final formViewModel = MeasurementSurveyFormViewModel(
              study: study, formData: MeasurementSurveyFormData.copyFrom(model));
          surveyMeasurementFormViewModels.add(formViewModel);
        },
        isAvailable: isNotReadonly,
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        isDestructive: true,
        onExecute: () {
          surveyMeasurementFormViewModels.removeWhere(
                  (vm) => vm.formData!.measurementId == model.measurementId);
        },
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction<ModelActionType>> availablePopupActions(
      MeasurementSurveyFormData model) {
    return availableActions(model).where(
            (action) => action.type != ModelActionType.edit).toList();
  }

  List<ModelAction<ModelActionType>> availableInlineActions(
      MeasurementSurveyFormData model) {
    return availableActions(model).where(
            (action) => action.type == ModelActionType.edit).toList();
  }

  @override
  void onSelectItem(MeasurementSurveyFormData item) {
    final studyId = study.id;
    final measurementId = item.measurementId;
    router.dispatch(RoutingIntents.studyEditMeasurement(studyId, measurementId));
  }

  @override
  void onNewItem() {
    final studyId = study.id;
    router.dispatch(
        RoutingIntents.studyEditMeasurement(studyId, Config.newModelId)
    );
  }

  // - IFormViewModelDelegate

  @override
  void onClose(MeasurementSurveyFormViewModel formViewModel, FormMode formMode) {
    return; // no-op
  }

  @override
  void onSave(MeasurementSurveyFormViewModel formViewModel, FormMode formMode) {
    if (formMode == FormMode.create) {
      print("onSave");
      surveyMeasurementFormViewModels.add(formViewModel);
      print("afteronSave");
    } else if (formMode == FormMode.edit) {
      // nothing to do here
    }
  }
}
