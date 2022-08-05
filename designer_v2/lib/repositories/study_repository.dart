import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';


abstract class IStudyRepository {
  // - Studies
  List<ModelAction<StudyActionType>> getAvailableActionsFor(Study study);
  Future<Study> duplicateStudy(Study study);
  Future<Study> saveStudy(Study study);
  Future<Study> publishStudy(Study study);
  Future<Study> fetchStudy(StudyID studyId);
  Stream<Study> watchStudy(StudyID studyId, {fetchOnSubscribe = true});
  Future<List<Study>> fetchUserStudies();
  Stream<List<Study>> watchUserStudies({fetchOnSubscribe = true});
  Future<void> deleteStudy(String id);
  // - Lifecycle
  void dispose();
}

class StudyRepository implements IStudyRepository {
  StudyRepository({
    required this.apiClient,
    required this.authRepository,
    required this.ref
  });

  /// Stream controller for broadcasting the studies that can be accessed by the current user
  final BehaviorSubject<List<Study>> _studiesStreamController =
      BehaviorSubject();

  /// Stream controllers for subscriptions on individual [Study] objects
  final Map<StudyID,BehaviorSubject<Study>> _studyStreamControllers = {};

  /// Reference to the StudyU API injected via Riverpod
  final StudyUApi apiClient;

  /// Reference to the auth repository injected via Riverpod
  final IAuthRepository authRepository;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final ProviderRef ref;

  /// Last emitted value for the list of studies
  List<Study> get _studyList {
    return _studiesStreamController.hasValue
        ? _studiesStreamController.value : [];
  }

  @override
  Future<List<Study>> fetchUserStudies() async {
    return await apiClient.getUserStudies();
  }

  @override
  Future<Study> fetchStudy(StudyID studyId) async {
    return await apiClient.fetchStudy(studyId);
  }

  @override
  Future<Study> saveStudy(Study study) async {
    final savedStudy = await apiClient.saveStudy(study);
    _upsertStudyLocally(savedStudy);
    return savedStudy;
  }

  @override
  Future<Study> duplicateStudy(Study study) async {
    final draftCopy = _createCleanDraftCopyFrom(study);
    final savedCopy = await apiClient.saveStudy(draftCopy);
    _upsertStudyLocally(savedCopy);
    return savedCopy;
  }

  @override
  List<ModelAction<StudyActionType>> getAvailableActionsFor(Study study) {
    Future<void> onDeleteCallback() {
      return deleteStudy(study.id)
        .then((value) => ref.read(routerProvider).dispatch(RoutingIntents.studies))
        .then((value) => Future.delayed(
            const Duration(milliseconds: 200),
            () => ref.read(notificationServiceProvider).show(
                Notifications.studyDeleted)
        ));
    }

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: "Edit".hardcoded,
        onExecute: () {
          ref.read(routerProvider)
              .dispatch(RoutingIntents.studyEdit(study.id));
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && study.status == StudyStatus.draft,
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: "Copy draft".hardcoded,
        onExecute: () {
          duplicateStudy(study);
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          // TODO open modal to add collaborator
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
      ModelAction(
        type: StudyActionType.recruit,
        label: "Recruit participants".hardcoded,
        onExecute: () {
          ref.read(routerProvider)
              .dispatch(RoutingIntents.studyRecruit(study.id));
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && study.status == StudyStatus.running,
      ),
      ModelAction(
        type: StudyActionType.export,
        label: "Export results".hardcoded,
        onExecute: () {
          // TODO trigger download of results
          print("Export results: ${study.title ?? ''}");
        },
        isAvailable: study.results.isNotEmpty
            && (study.isOwner(authRepository.currentUser!) ||
                study.isEditor(authRepository.currentUser!) ||
                study.resultSharing == ResultSharing.public),
      ),
      ModelAction(
        type: StudyActionType.delete,
        label: "Delete".hardcoded,
        onExecute: () {
          return ref.read(notificationServiceProvider).show(
            Notifications.studyDeleteConfirmation, // TODO: more severe confirmation for running studies
            actions: [
              NotificationAction(
                label: "Delete".hardcoded,
                onSelect: onDeleteCallback,
                isDestructive: true
              ),
            ]
          );
        },
        isAvailable: study.isOwner(authRepository.currentUser!)
            && !study.published,
        isDestructive: true
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }

  /// Creates a clean copy of the given [study] only containing the
  /// study protocol / editor data model
  _createCleanDraftCopyFrom(Study study) {
    // TODO: what's the best place for this logic without a server?
    // TODO: review Postgres access control policies
    final copy = Study.fromJson(study.toJson());
    copy.title = copy.title! + " (Copy)".hardcoded;
    copy.userId = authRepository.currentUser!.id;
    copy.published = false;
    copy.activeSubjectCount = 0;
    copy.participantCount = 0;
    copy.endedCount = 0;
    copy.missedDays = [];
    copy.resultSharing = ResultSharing.private;
    copy.results = [];
    copy.repo = null;
    copy.invites = null;
    copy.collaboratorEmails = [];

    // Generate a new random UID
    final dummy = Study.withId(authRepository.currentUser!.id);
    copy.id = dummy.id;

    return copy;
  }

  @override
  Future<Study> publishStudy(Study study) async {
    final publishedStudy = await apiClient.publishStudy(study);
    _upsertStudyLocally(publishedStudy);
    return publishedStudy;
  }

  @override
  Stream<List<Study>> watchUserStudies({fetchOnSubscribe = true}) {
    if (fetchOnSubscribe) {
      // We don't want to use Stream.fromFuture here because it automatically
      // closes the stream when the future resolves, but we want to keep
      // it open for future updates
      fetchUserStudies()
          .then((value) => _studiesStreamController.add(value))
          .catchError((e) => _studiesStreamController.addError(e));
    }
    return _studiesStreamController.stream;
  }

  /// Returns a stream that emits the [Study] identified by the given [StudyID].
  ///
  /// If [fetchOnSubscribe] is true, the individual study will be fetched
  /// from the network and upserted into the local cache.
  ///
  /// If the requested [Study] is not available via the [StudyUApi], the stream
  /// will be created anyway, but emit a [StudyNotFoundException] error event.
  @override
  Stream<Study> watchStudy(StudyID studyId, {fetchOnSubscribe = true}) {
    if (_studyStreamControllers.containsKey(studyId)) {
      return _studyStreamControllers[studyId]!.stream;
    }

    // Construct a transformed stream that selects the corresponding study from
    // the stream of all studies.
    //
    // It would be convenient to use a simple stream transform like .map here,
    // but this doesn't give us a way to send error events (e.g. from network
    // fetches) on the stream we are returning.
    //
    // Hence, we need to create a new controller here that implements
    // the stream transform as a subscription callback and cleans up after
    // itself when it's no longer needed.
    final BehaviorSubject<Study> controller = BehaviorSubject();
    final subscription = watchUserStudies(fetchOnSubscribe: false).listen(
            (studies) => controller.add(
                studies.firstWhere((study) => study.id == studyId)));

    void discardController() {
      subscription.cancel();
      controller.close();
      _studyStreamControllers.remove(studyId);
    }
    controller.onCancel = discardController;

    if (fetchOnSubscribe) {
      fetchStudy(studyId)
          .then((study) => _upsertStudyLocally(study))
          .catchError((e) => controller.addError(e));
    }

    return controller.stream;
  }

  /// Updates the client-side list of studies with a new [Study]
  ///
  /// Replaces the existing [Study] object locally (if it exists), otherwise
  /// appends the new object
  void _upsertStudyLocally(Study newStudy) {
    final studies = [..._studyList];
    final oldStudyIdx = studies.indexWhere((t) => t.id == newStudy.id);
    if (oldStudyIdx == -1) {
      // Study does not exist locally yet, add it to the client-side list
      studies.add(newStudy);
    } else {
      // Study already exists, replace with the new object
      studies[oldStudyIdx] = newStudy;
    }
    // Always re-emit to notify any stream subscribers
    _studiesStreamController.add(studies);
  }

  @override
  Future<void> deleteStudy(String id) async {
    // Re-emits the latest value added to the stream controller
    // minus the deleted object
    // TODO: proper error handling here
    final studies = [..._studyList];
    final studyIdx = studies.indexWhere((t) => t.id == id);
    if (studyIdx == -1) {
      throw StudyNotFoundException();
    } else {
      final study = studies[studyIdx];
      try {
        await apiClient.deleteStudy(study);
        // Update local state
        studies.removeAt(studyIdx);
        _studiesStreamController.add(studies);
      } catch(e) {
        print(e.toString());
        print("Something went wrong...");
      }
    }
  }

  @override
  dispose() {
    _studiesStreamController.close();
    _studyStreamControllers.forEach((_, controller) {
      controller.close();
    });
  }
}

final studyRepositoryProvider = Provider<IStudyRepository>((ref) {
  final studyRepository = StudyRepository(
      apiClient: ref.watch(apiClientProvider),
      authRepository: ref.watch(authRepositoryProvider),
      ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    studyRepository.dispose();
  });
  return studyRepository;
});
