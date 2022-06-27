import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState> {
  /// References to the data repositories injected by Riverpod
  final IStudyRepository studyRepository;
  final IAuthRepository authRepository;

  /// Reference to [GoRouter] injected via Riverpod
  /// Used to determine the [StudiesFilter] based on the current route
  final GoRouter router;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<List<Study>>? _studiesSubscription;

  DashboardController({
    required this.studyRepository,
    required this.authRepository,
    required this.router})
      : super(DashboardState(currentUser: authRepository.currentUser!)) {
    _subscribeStudies();
    _subscribeRouteUpdates();
  }

  _subscribeStudies() {
    // TODO: onError
    _studiesSubscription = studyRepository.watchUserStudies().listen((studies) {
      // Update the controller's state when new studies are available in the repository
      state = state.copyWith(
          status: () => DashboardStatus.success,
          studies: () => studies
      );
    });
  }

  _subscribeRouteUpdates() {
    router.addListener(_updateStudiesFilterFromRoute);
    _updateStudiesFilterFromRoute();
  }

  _updateStudiesFilterFromRoute() {
    Map<RouterPage,StudiesFilter> routeToFilter = {
      RouterPage.dashboard: StudiesFilter.owned,
      RouterPage.dashboardOwned: StudiesFilter.owned,
      RouterPage.dashboardShared: StudiesFilter.shared,
      RouterPage.registry: StudiesFilter.all,
    };
    routeToFilter.forEach((routerPage, studyFilter) {
      final pageLoc = router.namedLocation(routerPage.id);
      if (pageLoc == router.currentPath) {
        // Queue this up in the event loop to avoid state updates during render
        // A bit hacky...
        Future.delayed(
            const Duration(milliseconds: 0),
            () => setStudiesFilter(studyFilter)
        );
      }
    });
  }

  setStudiesFilter(StudiesFilter? filter) {
    state = state.copyWith(
        studiesFilter: () => filter ?? DashboardState.defaultFilter);
  }

  List<ModelAction<StudyActionType>> getAvailableActionsFor(Study study) {
    return [
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          // TODO open modal to add collaborator
          print("Adding collaborator: ${study.title ?? ''}");
        },
      ),
      ModelAction(
        type: StudyActionType.recruit,
        label: "Recruit participants".hardcoded,
        onExecute: () {
          // TODO navigate to recruit screen for the selected study
          print("Recruit participants: ${study.title ?? ''}");
        },
        // TODO: Add status field to core package domain model
        //isAvailable: study.status == StudyStatus.running,
        isAvailable: study.published,
      ),
      ModelAction(
        type: StudyActionType.export,
        label: "Export results".hardcoded,
        onExecute: () {
          // TODO trigger download of results
          print("Export results: ${study.title ?? ''}");
        },
        isAvailable: study.results.isNotEmpty,
      ),
      ModelAction(
          type: StudyActionType.delete,
          label: "Delete".hardcoded,
          onExecute: () {
            // Delegate the deletion request to the data & networking layer
            // Any changes are received back through the stream
            studyRepository.deleteStudy(study.id);
          },
          isAvailable: !study.published,
          isDestructive: true),
    ];
  }

  @override
  dispose() {
    _studiesSubscription?.cancel();
    router.removeListener(_updateStudiesFilterFromRoute);
    super.dispose();
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>(
        (ref) => DashboardController(
            studyRepository: ref.watch(studyRepositoryProvider),
            authRepository: ref.watch(authRepositoryProvider),
            router: ref.watch(routerProvider)
        ));
