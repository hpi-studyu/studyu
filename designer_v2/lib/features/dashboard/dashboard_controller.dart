import 'dart:async';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart' as core;
import 'dashboard_state.dart';


class DashboardController extends StateNotifier<DashboardState> {
  /// Initial value for the controller's state (see [StateNotifier])
  static const initialState = DashboardState();

  /// Reference to the data repository injected by Riverpod
  final StudyRepository studyRepository;

  /// A subscription for synchronizing state between the repository & controller
  StreamSubscription<List<core.Study>>? _studiesSubscription;

  DashboardController({required this.studyRepository}):
        super(initialState) {
    // Initialize the subscription
    _subscribeStudies();
  }

  _subscribeStudies() async {
    // TODO: onError
    _studiesSubscription = studyRepository.watchUserStudies().listen((studies) {
      // Update the controller's state when new studies are available in the repository
      state = state.copyWith(
          status: () => DashboardStatus.success,
          studies: () => studies
      );
    });
  }

  List<ModelAction<StudyActionType>> getAvailableActionsFor(core.Study study) {
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
        isDestructive: true
      ),
    ];
  }

  @override
  dispose() {
    _studiesSubscription?.cancel();
    super.dispose();
  }
}

final dashboardControllerProvider = StateNotifierProvider.autoDispose<DashboardController, DashboardState>((ref) {
  final studyRepository = ref.watch(studyRepositoryProvider);
  return DashboardController(studyRepository: studyRepository);
});