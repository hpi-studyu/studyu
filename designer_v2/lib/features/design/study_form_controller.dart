import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';


class StudyFormViewModel extends FormViewModel<Study>
    implements IFormViewModelDelegate<MeasurementsFormViewModel> {
  StudyFormViewModel({
    required this.router,
    required this.studyRepository,
    required super.formData, // Study
  }) {
    print("StudyFormViewModel.constructor");
    /*
    form.valueChanges.listen((event) {
      print("form updated");
      print(event);
    });

     */
  }

  /// On-write copy of the [Study] object managed by the view model
  Study? studyDirtyCopy;

  /// Reference to the study repository for saving / updating the study
  final IStudyRepository studyRepository;

  final GoRouter router;

  late final MeasurementsFormViewModel measurementsFormViewModel = MeasurementsFormViewModel(
    formData: MeasurementsFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    router: router,
  );

  //late final StudyInfoFormViewModel studyInfoFormViewModel = StudyInfoFormViewModel(
  //    data: StudyInfoFormData.fromStudy(data!), parent: this);
  //late final EnrollmentFormViewModel enrollmentFormViewModel = EnrollmentFormViewModel(
  //    data: EnrollmentFormData.fromStudy(data!), parent: this
  //);

  @override
  late final FormGroup form = FormGroup({
    //'info': studyInfoFormViewModel.form,
    //'enrollment': enrollmentFormViewModel.form,
    'measurements': measurementsFormViewModel.form,
  });

  @override
  void setControlsFrom(Study data) {
    //studyInfoFormViewModel.fromData(StudyInfoFormData.fromStudy(data));
    //enrollmentFormViewModel.fromData(EnrollmentFormData.fromStudy(data));
    measurementsFormViewModel.setControlsFrom(MeasurementsFormData.fromStudy(data));
  }

  @override
  Study buildFormData() {
    // TODO return updated study
    return formData!;
  }

  @override
  Future save() {
    if (studyDirtyCopy == null) {
      return Future.value(null); // nothing to do
    }
    // Flush the on-write study copy to the repository & clear it
    return studyRepository.save(studyDirtyCopy!)
        .then((study) => studyDirtyCopy = null);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: "TODO create",
    FormMode.edit: "TODO edit",
  };

  _applyAndSaveSubform(IStudyFormData subformData) {
    studyDirtyCopy ??= formData!.exactDuplicate();
    subformData.apply(studyDirtyCopy!);
    save();
  }

  void dispose() {
    print("StudyFormViewModel.dispose");
  }

  @override
  void onCancel(MeasurementsFormViewModel formViewModel, FormMode prevFormMode) {
    return; // nothing to do
  }

  @override
  void onSave(MeasurementsFormViewModel formViewModel, FormMode prevFormMode) {
    assert(prevFormMode == FormMode.edit);
    _applyAndSaveSubform(formViewModel.formData!);
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final studyFormViewModelProvider = Provider.autoDispose
    .family<StudyFormViewModel, StudyID>((ref, studyId) {
      print("studyFormViewModelProvider($studyId)");
      final studyController = ref.watch(studyControllerProvider(studyId).notifier);
      ref.onDispose(() {
        print("studyFormViewModelProvider($studyId).DISPOSE");
      });
      return studyController.studyFormViewModel;
});

/*
final studyInfoFormViewModelProvider = Provider.autoDispose
    .family<StudyInfoFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
});
 */

final measurementsFormViewModelProvider = Provider.autoDispose
    .family<MeasurementsFormViewModel, StudyID>((ref, studyId) {
      return ref.watch(
          studyFormViewModelProvider(studyId)).measurementsFormViewModel;
});

final surveyFormViewModelProvider = Provider.autoDispose
    .family<MeasurementSurveyFormViewModel,MeasurementFormRouteArgs>((ref, args) {
      final owner = ref.watch(measurementsFormViewModelProvider(args.studyId));
      return owner.provide(args);
});

final surveyQuestionFormViewModelProvider = Provider.autoDispose
    .family<SurveyQuestionFormViewModel,SurveyQuestionFormRouteArgs>((ref, args) {
      final owner = ref.watch(surveyFormViewModelProvider(args));
      return owner.provide(args);
});
