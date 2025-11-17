import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/features/study/study_test_app_routes.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class InterventionsFormViewModel extends FormViewModel<InterventionsFormData>
    with StudyScheduleControls
    implements
        IFormViewModelDelegate<InterventionFormViewModel>,
        IListActionProvider<InterventionFormViewModel>,
        IProviderArgsResolver<
          InterventionFormViewModel,
          InterventionFormRouteArgs
        > {
  InterventionsFormViewModel({
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

  final FormArray interventionsArray = FormArray([]);
  late final interventionsCollection =
      FormViewModelCollection<InterventionFormViewModel, InterventionFormData>(
        [],
        interventionsArray,
      );

  @override
  late final FormGroup form = FormGroup({
    'interventions': interventionsArray,
    ...studyScheduleControls,
  });

  // - Validation

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.draft]!,
    ],
    StudyFormValidationSet.publish: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.publish]!,
      interventionsRequired,
    ],
    StudyFormValidationSet.test: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.test]!,
      interventionsRequired,
    ],
  };

  FormControlValidation get interventionsRequired => FormControlValidation(
    control: interventionsArray,
    validators: [Validators.minLength(2)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_interventions_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  void setControlsFrom(InterventionsFormData data) {
    final viewModels = data.interventionsData
        .map(
          (data) => InterventionFormViewModel(
            study: study,
            formData: data,
            delegate: this,
            validationSet: validationSet,
          ),
        )
        .toList();
    interventionsCollection.reset(viewModels);
    setStudyScheduleControlsFrom(data.studyScheduleData);
  }

  @override
  InterventionsFormData buildFormData() {
    print('[DEBUG] buildFormData called');
    return InterventionsFormData(
      interventionsData: interventionsCollection.formData,
      studyScheduleData: buildStudyScheduleFormData(),
    );
  }

  @override
  Future save() async {
    print('[DEBUG] save() called');
    print('[DEBUG] Form valid: ${form.valid}');
    print('[DEBUG] Form dirty: $isDirty');
    try {
      await super.save();
      print('[DEBUG] save() completed successfully');
    } catch (e) {
      print('[DEBUG] save() failed with error: $e');
      rethrow;
    }
  }

  final List<StreamSubscription> _segmentSubscriptions = [];

  @override
  void enableAutosave({
    int debounce = Config.formAutosaveDebounce,
    bool onlyValid = true,
  }) {
    print('[DEBUG] enableAutosave called with debounce: $debounce');

    // Call parent implementation for normal form controls
    super.enableAutosave(debounce: debounce, onlyValid: onlyValid);

    // Additionally listen to segmentsControl changes
    // This is needed because FormArray changes are not automatically tracked
    // by the parent enableAutosave implementation

    // Listen to collection changes (add/remove segments)
    segmentsControl.collectionChanges.listen((_) {
      print('[DEBUG] segmentsControl.collectionChanges fired');
      print(
        '[DEBUG] Current segments count: ${segmentsControl.controls.length}',
      );
      // Update segments list from control
      updateSegmentsFromSegmentsControl();
      // Re-setup listeners for all segment controls
      _setupSegmentListeners(debounce);
      // Trigger save
      save();
    });

    // Setup initial listeners for existing segments
    print(
      '[DEBUG] Setting up initial listeners for ${segmentsControl.controls.length} segments',
    );
    _setupSegmentListeners(debounce);
  }

  void _setupSegmentListeners(int debounce) {
    print('[DEBUG] _setupSegmentListeners called');
    print(
      '[DEBUG] Cancelling ${_segmentSubscriptions.length} existing subscriptions',
    );

    // Cancel existing subscriptions
    for (final subscription in _segmentSubscriptions) {
      subscription.cancel();
    }
    _segmentSubscriptions.clear();

    // Create a debouncer for segment changes
    final segmentDebouncer = Debouncer(milliseconds: debounce, leading: false);

    // Listen to changes in each segment's FormControls
    int listenerCount = 0;
    for (int i = 0; i < segmentsControl.controls.length; i++) {
      final segmentControl = segmentsControl.controls[i];
      if (segmentControl is FormGroup) {
        print('[DEBUG] Setting up listeners for segment $i');
        for (final entry in segmentControl.controls.entries) {
          final controlName = entry.key;
          final control = entry.value;
          if (control is FormControl) {
            print(
              '[DEBUG]   - Listening to control: $controlName (current value: ${control.value})',
            );
            final subscription = control.valueChanges.listen((newValue) {
              print(
                '[DEBUG] Control $controlName changed to: $newValue in segment $i',
              );
              print('[DEBUG] Calling debounced save...');
              segmentDebouncer(
                futureBuilder: () async {
                  print(
                    '[DEBUG] Debouncer executing: updating segments and saving',
                  );
                  // Update segments list from control
                  updateSegmentsFromSegmentsControl();
                  // Trigger save
                  await save();
                  print('[DEBUG] Save completed');
                },
              );
            });
            _segmentSubscriptions.add(subscription);
            listenerCount++;
          }
        }
      }
    }
    print(
      '[DEBUG] Setup complete: $listenerCount listeners active across ${segmentsControl.controls.length} segments',
    );
    print('[DEBUG] Total subscriptions: ${_segmentSubscriptions.length}');
  }

  @override
  void dispose() {
    print(
      '[DEBUG] dispose called - cancelling ${_segmentSubscriptions.length} subscriptions',
    );
    for (final subscription in _segmentSubscriptions) {
      subscription.cancel();
    }
    _segmentSubscriptions.clear();
    super.dispose();
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // no title

  @override
  void read([InterventionsFormData? formData]) {
    interventionsCollection.read();
    super.read(formData);
  }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availableActions(
      model,
      onEdit: onSelectItem,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availablePopupActions(
      model,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availableInlineActions(
      model,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(InterventionFormViewModel item) {
    final studyId = study.id;
    final interventionId = item.interventionId;
    router.dispatch(
      RoutingIntents.studyEditIntervention(studyId, interventionId),
    );
  }

  @override
  void onNewItem() {
    final studyId = study.id;
    router.dispatch(
      RoutingIntents.studyEditIntervention(studyId, Config.newModelId),
    );
  }

  // - IProviderArgsResolver

  // TODO: factor this out into FormViewModelCollection
  @override
  InterventionFormViewModel provide(InterventionFormRouteArgs args) {
    if (args.interventionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = InterventionFormViewModel(
        study: study,
        delegate: this,
        validationSet: validationSet,
      );
      interventionsCollection.stage(viewModel);
      return viewModel;
    }

    final viewModel = interventionsCollection.findWhere(
      (vm) => vm.interventionId == args.interventionId,
    );
    if (viewModel == null) {
      throw InterventionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(InterventionFormViewModel formViewModel, FormMode formMode) {
    return; // no-op
  }

  @override
  Future onSave(
    InterventionFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      // Commit the managed viewmodel that was eagerly added in [provide]
      interventionsCollection.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    await super.save();
  }

  void testStudySchedule() {
    router.dispatch(
      RoutingIntents.studyTest(study.id, appRoute: TestAppRoutes.journey),
    );
  }

  bool get canTestStudySchedule =>
      !interventionsArray.disabled && interventionsArray.value!.length >= 2;
}
