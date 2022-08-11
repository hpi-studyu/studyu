import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState>
    implements IModelActionProvider<Study> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;

  /// Reference to services injected via Riverpod
  final GoRouter router;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  DashboardController({
    required this.studyRepository,
    required this.authRepository,
    required this.router,
  })
      : super(DashboardState(currentUser: authRepository.currentUser!)) {
    _subscribeStudies();
  }

  _subscribeStudies() {
    _studiesSubscription = studyRepository.watchAll().listen((wrappedModels) {
      // Update the controller's state when new studies are available in the repository
      final studies = wrappedModels.map((study) => study.model).toList();
      state = state.copyWith(
          studies: () => AsyncValue.data(studies),
      );
    }, onError: (error) {
      state = state.copyWith(
        studies: () => AsyncValue.error(error),
      );
    });
  }

  setStudiesFilter(StudiesFilter? filter) {
    state = state.copyWith(
        studiesFilter: () => filter ?? DashboardState.defaultFilter);
  }

  onSelectStudy(Study study) {
    router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  onClickNewStudy() {
    router.dispatch(RoutingIntents.studyNew);
  }

  @override
  List<ModelAction> availableActions(Study model) {
    return withIcons(
        studyRepository.availableActions(model), studyActionIcons);
  }

  @override
  dispose() {
    _studiesSubscription?.cancel();
    super.dispose();
  }
}

final dashboardControllerProvider =
    StateNotifierProvider.autoDispose<DashboardController, DashboardState>(
        (ref) => DashboardController(
            studyRepository: ref.watch(studyRepositoryProvider),
            authRepository: ref.watch(authRepositoryProvider),
            router: ref.watch(routerProvider),
        ));
