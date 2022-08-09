import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';


abstract class IStudyFormData {
  factory IStudyFormData.fromStudy(Study study) {
    throw UnimplementedError("Subclass responsibility");
  }
}

class StudyFormViewModel extends FormViewModel<Study> {
  StudyFormViewModel({
    required this.router,
    required super.formData,
  }) {
    _formChangesSubscription = form.valueChanges.listen((event) {
      // TODO: implement autosave if form is valid
      print("StudyFormViewModel.form.valueChanged");
    });
  }

  late final StreamSubscription _formChangesSubscription;

  late final MeasurementsFormViewModel measurementsFormViewModel = MeasurementsFormViewModel(
      study: formData!, formData: MeasurementsFormData.fromStudy(formData!), router: router);

  //late final StudyInfoFormViewModel studyInfoFormViewModel = StudyInfoFormViewModel(
  //    data: StudyInfoFormData.fromStudy(data!), parent: this);
  //late final EnrollmentFormViewModel enrollmentFormViewModel = EnrollmentFormViewModel(
  //    data: EnrollmentFormData.fromStudy(data!), parent: this
  //);

  final GoRouter router;

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
    // TODO
    return Future.value(true);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: "TODO create",
    FormMode.edit: "TODO edit",
  };
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final studyFormViewModelProvider = Provider
    .family<StudyFormViewModel, StudyID>((ref, studyId) {
  // Reactively bind to & obtain [StudyController]'s current study
  final study = ref.watch(
      studyControllerProvider(studyId).select((state) => state.study));
  return StudyFormViewModel(
      formData: study.value!,
      router: ref.watch(routerProvider),
  );
});

/*
final studyInfoFormViewModelProvider = Provider.autoDispose
    .family<StudyInfoFormViewModel, StudyID>((ref, studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
});
 */

final measurementsFormViewModelProvider = Provider
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
