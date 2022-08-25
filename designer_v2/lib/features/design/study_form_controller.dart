import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_data.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';


class StudyFormViewModel extends FormViewModel<Study>
    implements
        IFormViewModelDelegate<FormViewModel> {
  StudyFormViewModel({
    required this.router,
    required this.studyRepository,
    required this.authRepository,
    required super.formData, // Study
    super.validationSet = StudyFormValidationSet.draft,
  }) {
    if (isStudyReadonly) {
      read();
    }
  }

  /// On-write copy of the [Study] object managed by the view model
  Study? studyDirtyCopy;

  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;
  final GoRouter router;

  bool get isStudyReadonly =>
      formData?.isReadonly(authRepository.currentUser!) ?? false;

  late final StudyInfoFormViewModel studyInfoFormViewModel = StudyInfoFormViewModel(
    formData: StudyInfoFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    validationSet: validationSet,
  );

  late final EnrollmentFormViewModel enrollmentFormViewModel = EnrollmentFormViewModel(
    formData: EnrollmentFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    router: router,
    validationSet: validationSet,
  );

  late final MeasurementsFormViewModel measurementsFormViewModel = MeasurementsFormViewModel(
    formData: MeasurementsFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    router: router,
    validationSet: validationSet,
  );

  late final InterventionsFormViewModel interventionsFormViewModel = InterventionsFormViewModel(
    formData: InterventionsFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    router: router,
    validationSet: validationSet,
  );

  @override
  FormValidationConfigSet get validationConfig => {
    StudyFormValidationSet.draft: [], // TODO
    StudyFormValidationSet.publish: [], // TODO
    StudyFormValidationSet.test: [], // TODO
  };

  @override
  late final FormGroup form = FormGroup({
    'info': studyInfoFormViewModel.form,
    'enrollment': enrollmentFormViewModel.form,
    'measurements': measurementsFormViewModel.form,
    'interventions': interventionsFormViewModel.form,
  });

  @override
  void read([Study? formData]) {
    // Put all subforms into readonly mode
    studyInfoFormViewModel.read();
    enrollmentFormViewModel.read();
    measurementsFormViewModel.read();
    interventionsFormViewModel.read();
    super.read(formData);
  }

  @override
  void setControlsFrom(Study data) {
    return; // subforms manage their own controls
  }

  @override
  Study buildFormData() {
    return formData!;
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  @override
  void dispose() {
    studyInfoFormViewModel.dispose();
    enrollmentFormViewModel.dispose();
    interventionsFormViewModel.dispose();
    measurementsFormViewModel.dispose();
    super.dispose();
  }

  @override
  void onCancel(FormViewModel formViewModel, FormMode prevFormMode) {
    return; // nothing to do
  }

  @override
  void onSave(FormViewModel formViewModel, FormMode prevFormMode) {
    assert(prevFormMode == FormMode.edit);
    _applyAndSaveSubform(formViewModel.formData!);
  }

  Future _flushDirtyStudy() {
    if (studyDirtyCopy == null) {
      return Future.value(null); // nothing to do
    }
    // Flush the on-write study copy to the repository & clear it
    return studyRepository.save(studyDirtyCopy!)
        .then((study) => studyDirtyCopy = null);
  }

  _applyAndSaveSubform(IStudyFormData subformData) {
    studyDirtyCopy ??= formData!.exactDuplicate();
    subformData.apply(studyDirtyCopy!);
    _flushDirtyStudy();
  }
}

/// Provides the the [FormViewModel] that is responsible for displaying &
/// editing the survey design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final studyFormViewModelProvider = Provider.autoDispose
    .family<StudyFormViewModel, StudyID>((ref, studyId) {
  print("studyFormViewModelProvider");
  final state = ref.watch(studyControllerProvider(studyId));
  final formViewModel = StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    formData: state.study.value,
  );

  ref.onDispose(() {
    formViewModel.dispose();
    print("studyFormViewModelProvider.DISPOSE");
  });

  return formViewModel;
});
