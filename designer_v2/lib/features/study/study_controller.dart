import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_base_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class StudyController extends StudyBaseController<StudyControllerState> {
  StudyController({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required this.authRepository,
    required this.notificationService,
  }) : super(const StudyControllerState());

  final IAuthRepository authRepository;
  final INotificationService notificationService;

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
        studyRepository
            .availableActions(study)
            .where((action) => action.type != StudyActionType.edit)
            .toList() as List<ModelAction<StudyActionType>>,
        studyActionIcons);
  }

  Future<void> publishStudy() {
    return studyRepository
        .publish(state.study.value!)
        .then((_) => null); // TODO: save study repository form view model setting
  }

  void onChangeStudyParticipation() {
    router.dispatch(RoutingIntents.studyEditEnrollment(studyId));
  }

  void onAddParticipants() {
    router.dispatch(RoutingIntents.studyRecruit(studyId));
  }
}

/// Use the [family] modifier to provide a controller parametrized by [StudyID]
final studyControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyController, StudyControllerState, StudyID>((ref, studyId) {
  print("studyControllerProvider($studyId)");
  final controller = StudyController(
    studyId: studyId,
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    router: ref.watch(routerProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
  ref.onDispose(() {
    print("studyControllerProvider($studyId).DISPOSE");
  });
  return controller;
});
