import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyController extends StudyBaseController<StudyControllerState> {
  StudyController({
    required super.studyId,
    required super.studyRepository,
    required super.router,
  }) : super(const StudyControllerState());

  /// The [FormViewModel] that is responsible for displaying & editing the
  /// survey design form. Its lifecycle is bound to the study controller.
  ///
  /// Note:This is not safe to access before the [StudyControllerState.study]
  /// is available
  late final StudyFormViewModel studyFormViewModel = StudyFormViewModel(
      router: router,
      studyRepository: studyRepository,
      formData: state.study.value!
  );

  @override
  onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    super.onStudySubscriptionUpdate(wrappedModel);
    final studyId = wrappedModel.model.id;
    _redirectNewToActualStudyID(studyId);
  }

  /// Redirect to the study-specific URL to avoid disposing a dirty controller
  /// when building subroutes
  _redirectNewToActualStudyID(StudyID actualStudyId) {
    if (studyId == Config.newModelId) {
      router.dispatch(RoutingIntents.study(actualStudyId));
    }
  }

  List<ModelAction<StudyActionType>> get studyActions {
    final study = state.study.value;
    if (study == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
        studyRepository.availableActions(study).where(
                (action) => action.type != StudyActionType.edit)
            .toList() as List<ModelAction<StudyActionType>>,
        studyActionIcons
    );
  }

  @override
  dispose() {
    studyFormViewModel.dispose();
    super.dispose();
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
  .family<StudyController, StudyControllerState, StudyID>((ref, studyId) {
    print("studyControllerProvider($studyId)");
    ref.onDispose(() {
      print("studyControllerProvider($studyId).DISPOSE");
    });
    return StudyController(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
    );
});
