import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class MeasurementsFormViewModel extends FormViewModel<MeasurementsFormData>
    implements IFormViewModelDelegate<MeasurementSurveyFormViewModel>,
        IListActionProvider<ModelActionType, MeasurementSurveyFormData>,
        IProviderArgsResolver<MeasurementSurveyFormViewModel, MeasurementFormRouteArgs> {

  MeasurementsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
  });

  final Study study;
  final GoRouter router;

  // - Form fields

  //FormArray get measurementsArray => surveyMeasurementFormViewModels.formArray;
  final FormArray measurementsArray = FormArray([],
      validators: [Validators.minLength(1)]);

  late final surveyMeasurementFormViewModels = FormViewModelCollection<
      MeasurementSurveyFormViewModel, MeasurementSurveyFormData>([], measurementsArray);

  List<MeasurementSurveyFormData> get measurementsData =>
      surveyMeasurementFormViewModels.formData;

  @override
  late final FormGroup form = FormGroup({
    'surveyMeasurements': measurementsArray,
  });

  @override
  void setControlsFrom(MeasurementsFormData data) {
    final viewModels = data.surveyMeasurements.map(
            (data) => MeasurementSurveyFormViewModel(
            study: study, formData: data, delegate: this
        )).toList();
    surveyMeasurementFormViewModels.reset(viewModels);

    /*
    for (final surveyMeasurement in data.surveyMeasurements) {
      surveyMeasurementFormViewModels.add(
          MeasurementSurveyFormViewModel(
              study: study, formData: surveyMeasurement, delegate: this));
    }

     */
  }

  @override
  MeasurementsFormData buildFormData() {
    return MeasurementsFormData(
      surveyMeasurements: surveyMeasurementFormViewModels.formData,
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
            study: study,
            formData: model.copy(),
            delegate: this,
          );
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

  // - IProviderArgsResolver

  @override
  MeasurementSurveyFormViewModel provide(MeasurementFormRouteArgs args) {
    if (args.measurementId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = MeasurementSurveyFormViewModel(
          study: study, formData: null, delegate: this);
      surveyMeasurementFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = surveyMeasurementFormViewModels.findWhere(
            (vm) => vm.measurementId == args.measurementId);
    if (viewModel == null) {
      throw MeasurementNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(MeasurementSurveyFormViewModel formViewModel, FormMode formMode) {
    return; // no-op
  }

  @override
  void onSave(MeasurementSurveyFormViewModel formViewModel, FormMode prevFormMode) {
    if (prevFormMode == FormMode.create) {
      // Commit the managed viewmodel that was eagerly added in [provide]
      surveyMeasurementFormViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    super.save();
  }
}
