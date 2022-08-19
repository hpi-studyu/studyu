import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

// TODO save results
// TODO figure out study registry visibility
class StudySettingsFormViewModel extends FormViewModel<Study> {
  StudySettingsFormViewModel({
    required this.studyRepository,
    required super.formData, // Study
    //super.autosave = true,
  });

  final IStudyRepository studyRepository;

  final FormControl<bool> isPublishedToRegistryControl = FormControl();
  final FormControl<bool> isPublishedToRegistryResultsControl = FormControl();

  @override
  late final FormGroup form = FormGroup({
    'isPublishedToRegistry': isPublishedToRegistryControl,
    'isPublishedToRegistryResults': isPublishedToRegistryResultsControl,
  });

  @override
  void setControlsFrom(Study data) {
    // TODO figure out registry visibility, how does it work now?
    isPublishedToRegistryControl.value = data.publishedToRegistry;
    isPublishedToRegistryResultsControl.value = data.publishedToRegistryResults;
  }

  @override
  Study buildFormData() {
    return formData!;
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused
}
/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
final studySettingsFormViewModelProvider = Provider.autoDispose
    .family<StudySettingsFormViewModel, StudyID>((ref, studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  final formViewModel = StudySettingsFormViewModel(
    studyRepository: ref.watch(studyRepositoryProvider),
    formData: state.study.value!,
  );
  ref.onDispose(() {
    print("studySettingsFormViewModelProvider.DISPOSE");
  });
  return formViewModel;
});
