import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_question_form.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';


class MeasurementsFormData implements IStudyFormData {
  final List<MeasurementSurveyFormData> surveyMeasurements;

  MeasurementsFormData({required this.surveyMeasurements});

  factory MeasurementsFormData.fromStudy(Study study) {
    /*
    return MeasurementsFormData(
        surveyMeasurements: (study.observations).map(
            (observation) => MeasurementSurveyFormData(
                questionnaireTask: (observation as QuestionnaireTask))
        ).toList()
    );
     */
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

  final List<MeasurementSurveyFormViewModel> surveyMeasurementFormViewModels = [];
  List<MeasurementSurveyFormData> get surveyMeasurementFormDataArray =>
      surveyMeasurementFormViewModels.map((vm) => vm.data!).toList();

  // - IProviderArgsResolver

  @override
  MeasurementSurveyFormViewModel provide(MeasurementFormRouteArgs args) {
    if (args.measurementId == Config.newModelId) {
      return MeasurementSurveyFormViewModel(
          study: study, formData: null, delegate: this);
    }
    // TODO handle 404 not found
    final idx = surveyMeasurementFormViewModels.indexWhere(
            (vm) => vm.data!.measurementId == args.measurementId);
    return surveyMeasurementFormViewModels[idx];
  }

  // - Form fields

  FormArray get surveyMeasurementsArray => FormArray(
      surveyMeasurementFormViewModels.map((vm) => vm.form).toList());

  @override
  FormGroup get form => FormGroup({
    'surveyMeasurements': surveyMeasurementsArray,
  });

  @override
  void fromData(MeasurementsFormData data) {
    for (final surveyMeasurement in data.surveyMeasurements) {
      surveyMeasurementFormViewModels.add(
          MeasurementSurveyFormViewModel(
              study: study, formData: surveyMeasurement, delegate: this));
    }
  }

  @override
  MeasurementsFormData toData() {
    return MeasurementsFormData(
        surveyMeasurements: surveyMeasurementFormViewModels.map(
                (vm) => vm.toData()).toList()
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IListActionProvider

  @override
  List<ModelAction<ModelActionType>> availableActions(MeasurementSurveyFormData model) {
    // TODO
    // Edit => go to subpage
    // Delete => remove child view model
    // Copy => copy + insert child view model
    return [];
  }

  @override
  void onSelectItem(MeasurementSurveyFormData item) {
    final studyId = study.id;
    final measurementId = item.measurementId;
    router.dispatch(RoutingIntents.studyEditMeasurement(studyId, measurementId));
  }

  @override
  void onNewItem() {
    // do we push the child view model already? no, only on save (so that we can still cancel)
    // do we actually need childformviewmodel or wouldn't delegate be better?
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
      surveyMeasurementFormViewModels.add(formViewModel);
    } else if (formMode == FormMode.edit) {
      // nothing to do here
    }
  }
}
