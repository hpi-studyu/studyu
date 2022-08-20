import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';

enum FileType {
  csv, json;

  @override
  String toString() {
    switch(this) {
      case FileType.csv:
        return "CSV".hardcoded;
      case FileType.json:
        return "JSON".hardcoded;
    }
  }
}

class StudyAnalyzeController
    extends StudyBaseController<StudyControllerBaseState> {
  StudyAnalyzeController({
    required super.studyId,
    required super.studyRepository,
    required super.router,
  }) : super(const StudyControllerBaseState());

  FormControl<FileType> fileTypeControl = FormControl(value: FileType.csv);

  List<FormControlOption<FileType>> get fileTypeControlOptions =>
      FileType.values
          .map((value) => FormControlOption(value, value.toString()))
          .toList();

  late final FormGroup form = FormGroup({
    "fileType": fileTypeControl,
  });

  Future<void> onExport() {
    final fileType = fileTypeControl.value!;
    return Future.value(null); // TODO trigger download
  }
}

final studyAnalyzeControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyAnalyzeController, StudyControllerBaseState, StudyID>(
        (ref, studyId) {
  return StudyAnalyzeController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    router: ref.watch(routerProvider),
  );
});
