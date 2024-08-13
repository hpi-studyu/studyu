import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

part 'study_settings_form_controller.g.dart';

class StudySettingsFormViewModel extends FormViewModel<Study> {
  StudySettingsFormViewModel({
    required this.studyRepository,
    required this.study,
  }) : super(formData: study.value) {
    // defer registering listeners so that controls can be initialized properly
    runAsync(keepControlsSynced);
  }

  final AsyncValue<Study> study;
  final IStudyRepository studyRepository;

  static const defaultPublishedToRegistry = true;
  static const defaultPublishedToRegistryResults = false;

  final FormControl<bool> isPublishedToRegistryControl =
      FormControl(value: defaultPublishedToRegistry);
  final FormControl<bool> isPublishedToRegistryResultsControl =
      FormControl(value: defaultPublishedToRegistryResults);
  final FormControl<bool> lockPublishSettingsControl = FormControl();

  @override
  late final FormGroup form = FormGroup({
    'isPublishedToRegistry': isPublishedToRegistryControl,
    'isPublishedToRegistryResults': isPublishedToRegistryResultsControl,
    'lockStudySettings': lockPublishSettingsControl,
  });

  @override
  void setControlsFrom(Study data) {
    isPublishedToRegistryControl.value = data.publishedToRegistry;
    isPublishedToRegistryResultsControl.value = data.publishedToRegistryResults;
    lockPublishSettingsControl.value =
        data.templateConfiguration?.lockStudySettings ?? false;

    //disable editing registry controls if study is template and running OR if study is sub-study and publish settings are locked
    //in other words template studies cannot change its registry settings while running and sub-studies cannot change its registry settings if publish settings are locked
    if ((data.isTemplate && data.status == StudyStatus.running) ||
        (data.isSubStudy && lockPublishSettingsControl.value == true)) {
      isPublishedToRegistryControl.markAsDisabled();
      isPublishedToRegistryResultsControl.markAsDisabled();
    }

    if (data.isTemplate && data.status == StudyStatus.running ||
        data.isSubStudy) {
      lockPublishSettingsControl.markAsDisabled();
    }
  }

  @override
  Study buildFormData() {
    final study = formData!.exactDuplicate();

    study.registryPublished = isPublishedToRegistryControl.value!;
    study.resultSharing = (isPublishedToRegistryResultsControl.value!)
        ? ResultSharing.public
        : ResultSharing.private;
    study.templateConfiguration = study.templateConfiguration?.copyWith(
      lockStudySettings: lockPublishSettingsControl.value,
    );

    return study;
  }

  void keepControlsSynced() {
    // sync controls so that results cannot be published without publishing
    // the study design itself
    isPublishedToRegistryControl.valueChanges.listen((value) {
      if (value == false) {
        isPublishedToRegistryResultsControl.value = false;
      }
    });
    isPublishedToRegistryResultsControl.valueChanges.listen((value) {
      if (value == true) {
        isPublishedToRegistryControl.value = true;
      }
    });
  }

  @override
  Future save() {
    final study = buildFormData();
    return studyRepository.save(study);
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  void setLaunchDefaults() {
    isPublishedToRegistryControl.value = defaultPublishedToRegistry;
    isPublishedToRegistryResultsControl.value =
        defaultPublishedToRegistryResults;

    lockPublishSettingsControl.value = false;
  }
}

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
@riverpod
StudySettingsFormViewModel studySettingsFormViewModel(
  StudySettingsFormViewModelRef ref,
  StudyCreationArgs studyCreationArgs,
) {
  final state = ref.watch(studyControllerProvider(studyCreationArgs));
  final formViewModel = StudySettingsFormViewModel(
    studyRepository: ref.watch(studyRepositoryProvider),
    study: state.study,
  );
  ref.onDispose(() {
    print("studySettingsFormViewModelProvider.DISPOSE");
  });
  return formViewModel;
}
