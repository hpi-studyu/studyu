import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class MeasurementsFormViewModel extends FormViewModel<MeasurementsFormData>
    implements
        IFormViewModelDelegate<ManagedFormViewModel>,
        IListActionProvider<ManagedFormViewModel>,
        IProviderArgsResolver<dynamic, MeasurementFormRouteArgs> {
  MeasurementsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet.draft,
  });

  final Study study;
  final GoRouter router;

  // - Form fields

  final FormArray measurementsArray = FormArray([]);
  late final measurementViewModelsCollection =
      FormViewModelCollection<
        ManagedFormViewModel<IFormDataWithSchedule>,
        IFormDataWithSchedule
      >([], measurementsArray);

  List<ManagedFormViewModel<IFormDataWithSchedule>> get measurementViewModels =>
      measurementViewModelsCollection.formViewModels;

  bool get canAddMeasurement => study.status == StudyStatus.draft;

  bool get isNutritionEnabled =>
      measurementViewModels.any((vm) => vm is NutritionFormViewModel);

  set isNutritionEnabled(bool enabled) {
    if (enabled) {
      if (!isNutritionEnabled) {
        onNewNutrition();
      }
    } else {
      final nutritionVm = measurementViewModels
          .whereType<NutritionFormViewModel>()
          .firstOrNull;
      if (nutritionVm != null) {
        measurementViewModelsCollection.remove(nutritionVm);
      }
    }
  }

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [],
    StudyFormValidationSet.publish: [measurementRequired],
    StudyFormValidationSet.test: [],
  };

  FormControlValidation get measurementRequired => FormControlValidation(
    control: measurementsArray,
    validators: [Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_measurements_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  late final FormGroup form = FormGroup({'measurements': measurementsArray});

  @override
  void read([MeasurementsFormData? formData]) {
    measurementViewModelsCollection.read();
    super.read(formData);
  }

  @override
  void setControlsFrom(MeasurementsFormData data) {
    final viewModels = data.measurements
        .map((data) {
          if (data is MeasurementSurveyFormData) {
            return MeasurementSurveyFormViewModel(
              study: study,
              formData: data,
              delegate: this,
              validationSet: validationSet,
            );
          } else if (data is NutritionFormData) {
            return NutritionFormViewModel(
              study: study,
              formData: data,
              delegate: this,
              validationSet: validationSet,
            );
          }
          throw UnimplementedError();
        })
        .cast<ManagedFormViewModel<IFormDataWithSchedule>>()
        .toList();
    measurementViewModelsCollection.reset(viewModels);
  }

  @override
  MeasurementsFormData buildFormData() {
    return MeasurementsFormData(
      measurements: measurementViewModelsCollection.formData,
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availableActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      onEdit: onSelectItem,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availablePopupActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availableInlineActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(ManagedFormViewModel item) {
    final studyId = study.id;
    final MeasurementID measurementId =
        (item as dynamic).measurementId as MeasurementID;
    router.dispatch(
      RoutingIntents.studyEditMeasurement(studyId, measurementId),
    );
  }

  @override
  void onNewItem() {
    onNewSurvey();
  }

  void onNewSurvey() {
    final studyId = study.id;
    router.dispatch(
      RoutingIntents.studyEditMeasurement(studyId, Config.newModelId),
    );
  }

  void onNewNutrition() {
    final studyId = study.id;
    router.dispatch(
      RoutingIntents.studyEditMeasurement(
        studyId,
        Config.newModelId,
        queryParameters: {'type': 'nutrition'},
      ),
    );
  }

  // --- FFQ lookup cache ---
  bool? _isFFQEnabledCache;
  bool? _isFFQ14DayEnabledCache;
  Set<String>? _addedFFQDayTitlesCache;

  void _invalidateFFQCache() {
    _isFFQEnabledCache = null;
    _isFFQ14DayEnabledCache = null;
    _addedFFQDayTitlesCache = null;
  }

  Set<String> get _addedFFQDayTitles {
    if (_addedFFQDayTitlesCache != null) return _addedFFQDayTitlesCache!;
    final titles = <String>{};
    for (final vm in measurementViewModels) {
      if (vm is MeasurementSurveyFormViewModel) {
        final title = vm.formData?.title ?? '';
        if (FFQQuestions.isFFQDayTask(title)) {
          titles.add(title);
        }
      }
    }
    _addedFFQDayTitlesCache = titles;
    return titles;
  }

  bool get isFFQEnabled {
    if (_isFFQEnabledCache != null) return _isFFQEnabledCache!;
    _isFFQEnabledCache = measurementViewModels.any((vm) {
      if (vm is MeasurementSurveyFormViewModel) {
        final title = vm.formData?.title ?? '';
        return (title.contains('Food Frequency Questionnaire') ||
                title.contains('FFQ')) &&
            !FFQQuestions.isFFQDayTask(title);
      }
      return false;
    });
    return _isFFQEnabledCache!;
  }

  bool get isFFQ14DayEnabled {
    if (_isFFQ14DayEnabledCache != null) return _isFFQ14DayEnabledCache!;
    _isFFQ14DayEnabledCache = _addedFFQDayTitles.isNotEmpty;
    return _isFFQ14DayEnabledCache!;
  }

  /// True if the survey for [dayIndex] (0..13) is already added.
  bool isFFQDaySurveyAdded(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= FFQQuestions.ffqDaySurveyTitles.length) {
      return false;
    }
    final title = FFQQuestions.ffqDaySurveyTitles[dayIndex];
    return _addedFFQDayTitles.contains(title);
  }

  void onNewFFQ() {
    final ffqTask = FFQQuestions.createFFQTask();
    final ffqFormData = MeasurementSurveyFormData.fromDomainModel(ffqTask);
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      formData: ffqFormData,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.add(viewModel);
    _invalidateFFQCache();
    onSelectItem(viewModel);
  }

  /// Add a single FFQ survey for the given day index (0..13).
  /// Returns the created view model, or null if it was already added or index is invalid.
  MeasurementSurveyFormViewModel? onNewFFQForDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= FFQQuestions.ffqDaySurveyTitles.length) {
      return null;
    }
    if (isFFQDaySurveyAdded(dayIndex)) return null;
    final task = FFQQuestions.createFFQTaskForDay(dayIndex);
    // Compute default study day for this survey
    final phaseDuration = study.schedule.phaseDuration;
    final baseDay =
        study.schedule.includeBaseline ? phaseDuration : 0;
    task.scheduledStudyDay = dayIndex < 7
        ? baseDay + dayIndex
        : baseDay + phaseDuration + (dayIndex - 7);
    final ffqFormData = MeasurementSurveyFormData.fromDomainModel(task);
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      formData: ffqFormData,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.add(viewModel);
    _invalidateFFQCache();
    return viewModel;
  }

  /// Update the scheduled study day for an existing FFQ survey.
  void updateFFQDaySchedule(int dayIndex, int newStudyDay) {
    if (dayIndex < 0 || dayIndex >= FFQQuestions.ffqDaySurveyTitles.length) {
      return;
    }
    final title = FFQQuestions.ffqDaySurveyTitles[dayIndex];
    for (final vm in measurementViewModels) {
      if (vm is MeasurementSurveyFormViewModel) {
        if (vm.formData?.title == title) {
          // Update the control directly to preserve form state
          vm.scheduledStudyDayControl.value = newStudyDay;
          vm.scheduledStudyDayControl.markAsDirty();
          break;
        }
      }
    }
  }

  /// Get the current scheduledStudyDay for an FFQ survey by dayIndex.
  int? getFFQDayScheduledStudyDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= FFQQuestions.ffqDaySurveyTitles.length) {
      return null;
    }
    final title = FFQQuestions.ffqDaySurveyTitles[dayIndex];
    for (final vm in measurementViewModels) {
      if (vm is MeasurementSurveyFormViewModel) {
        if (vm.formData?.title == title) {
          // Read from control if available, otherwise fallback to form data
          return vm.scheduledStudyDayControl.value ??
              vm.formData?.scheduledStudyDay;
        }
      }
    }
    return null;
  }

  // - IProviderArgsResolver

  @override
  dynamic provide(MeasurementFormRouteArgs args) {
    if (args.measurementId.isNewId) {
      return _provideNewSurvey();
    }

    final viewModel = measurementViewModelsCollection.findWhere(
      (vm) => (vm as dynamic).measurementId == args.measurementId,
    );
    if (viewModel != null) {
      return viewModel;
    }

    throw MeasurementNotFoundException();
  }

  dynamic provideWithType(MeasurementFormRouteArgs args, String? type) {
    if (args.measurementId.isNewId) {
      if (type == 'nutrition') {
        return _provideNewNutrition();
      }
      return _provideNewSurvey();
    }
    return provide(args);
  }

  MeasurementSurveyFormViewModel _provideNewSurvey() {
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.stage(viewModel);
    return viewModel;
  }

  NutritionFormViewModel _provideNewNutrition() {
    final viewModel = NutritionFormViewModel(
      study: study,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.stage(viewModel);
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(ManagedFormViewModel formViewModel, FormMode formMode) {
    return; // no-op
  }

  @override
  Future onSave(
    ManagedFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      measurementViewModelsCollection.commit(
        formViewModel as ManagedFormViewModel<IFormDataWithSchedule>,
      );
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    await super.save();
  }
}
