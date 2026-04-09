import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart'
    show
        BorderRadius,
        BoxConstraints,
        BoxDecoration,
        Column,
        ConstrainedBox,
        Container,
        CrossAxisAlignment,
        Colors,
        EdgeInsets,
        FontWeight,
        Icon,
        Icons,
        ListTile,
        MainAxisSize,
        Row,
        SingleChildScrollView,
        SizedBox,
        Text,
        TextStyle;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController
    implements IModelActionProvider<Study> {
  @override
  DashboardState build() {
    _studyRepository = ref.watch(studyRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _router = ref.watch(routerProvider);

    ref.onDispose(() {
      print("dashboardControllerProvider.DISPOSE");
      _studiesSubscription?.cancel();
    });

    listenSelf((previous, next) {
      print("dashboardController.state updated");
    });

    _subscribeStudies();
    _loadUserPreferences();

    return DashboardState(
      currentUser: _authRepository.currentUser!,
      searchController: SearchController(),
    );
  }

  /// References to the data repositories injected by Riverpod
  late final IStudyRepository _studyRepository;
  late final IAuthRepository _authRepository;
  late final IUserRepository _userRepository;

  /// Reference to services injected via Riverpod
  late final GoRouter _router;

  /// A subscription for synchronizing state between the repository and the controller
  StreamSubscription<List<WrappedModel<Study>>>? _studiesSubscription;

  NotificationService get _notificationService =>
      ref.read(notificationServiceProvider);

  void _setBulkActionInProgress(bool value, {int totalCount = 0}) {
    state = state.copyWith(
      isBulkActionInProgress: value,
      bulkActionCompletedCount: value ? 0 : 0,
      bulkActionTotalCount: value ? totalCount : 0,
    );
  }

  void _advanceBulkActionProgress() {
    state = state.copyWith(
      bulkActionCompletedCount: state.bulkActionCompletedCount + 1,
    );
  }

  Future<void> _loadUserPreferences() async {
    try {
      await _userRepository.fetchUser();

      final savedFilters = _userRepository.getCustomPresets();
      const defaultFilter = DashboardState.defaultFilter;
      final pageKey = _getPageKey(defaultFilter);
      final active = _userRepository.getActiveFilter(pageKey);

      state = state.copyWith(
        savedFilters: () => savedFilters,
        activeFilter: () => active.filterGroup,
        selectedSavedFilterId: () => active.presetId,
      );
    } catch (e) {
      print("Failed to load user preferences: $e");
    }
  }

  void _subscribeStudies() {
    _studiesSubscription = _studyRepository.watchAll().listen(
      (wrappedModels) {
        print("studyRepository.update");
        // Update the controller's state when new studies are available in the repository
        final studies = wrappedModels.map((study) => study.model).toList();
        state = state.copyWith(studies: () => AsyncValue.data(studies));
      },
      onError: (Object error) {
        state = state.copyWith(
          studies: () => AsyncValue.error(error, StackTrace.current),
        );
      },
    );
  }

  void setSearchText(String? text) {
    state.searchController.setText(text ?? state.query);
  }

  Future<void> setStudiesFilter(StudiesFilter? filter) async {
    await _userRepository.fetchUser();
    final newFilter = filter ?? DashboardState.defaultFilter;
    final pageKey = _getPageKey(newFilter);
    final active = _userRepository.getActiveFilter(pageKey);

    state = state.copyWith(
      studiesFilter: () => newFilter,
      activeFilter: () => active.filterGroup,
      selectedSavedFilterId: () => active.presetId,
    );
  }

  void updateFilter(FilterGroup filter, {String? presetId}) {
    state = state.copyWith(
      activeFilter: () => filter,
      selectedSavedFilterId: () => presetId,
    );
    // Persist change
    final pageKey = _getPageKey(state.studiesFilter);
    _userRepository.saveActiveFilter(
      page: pageKey,
      presetId: presetId,
      filterGroup: filter,
    );
  }

  Future<void> saveFilter(SavedFilter filter) async {
    await _userRepository.saveCustomPreset(filter);
    // Reload to reflect changes
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  Future<void> deleteFilter(String id) async {
    await _userRepository.deleteCustomPreset(id);
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  String _getPageKey(StudiesFilter? filter) {
    return switch (filter) {
      StudiesFilter.owned => 'my_studies',
      StudiesFilter.shared => 'shared_studies',
      StudiesFilter.public => 'public_studies',
      StudiesFilter.all => 'all_studies',
      null => 'my_studies', // Default
    };
  }

  void onSelectStudy(Study study) {
    _router.dispatch(RoutingIntents.studyEdit(study.id));
  }

  void onClickNewStudy() {
    final Study newStudy = _studyRepository.delegate.createNewInstance();
    newStudy.save();
    _router.dispatch(RoutingIntents.studyEdit(newStudy.id));
  }

  Future<void> pinStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pin, modelId);
    sortStudies();
  }

  Future<void> pinOffStudy(String modelId) async {
    await _userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
    sortStudies();
  }

  void toggleStudySelection(String studyId) {
    final updatedSelection = {...state.selectedStudyIds};
    if (!updatedSelection.add(studyId)) {
      updatedSelection.remove(studyId);
    }
    state = state.copyWith(selectedStudyIds: updatedSelection);
  }

  void setStudySelection(String studyId, bool selected) {
    final updatedSelection = {...state.selectedStudyIds};
    if (selected) {
      updatedSelection.add(studyId);
    } else {
      updatedSelection.remove(studyId);
    }
    state = state.copyWith(selectedStudyIds: updatedSelection);
  }

  void toggleSelectAllVisibleStudies(List<Study> visibleStudies) {
    final visibleIds = visibleStudies.map((study) => study.id).toSet();
    final allVisibleSelected = visibleIds.isNotEmpty &&
        visibleIds.every(state.selectedStudyIds.contains);

    final updatedSelection = {...state.selectedStudyIds};
    if (allVisibleSelected) {
      updatedSelection.removeAll(visibleIds);
    } else {
      updatedSelection.addAll(visibleIds);
    }
    state = state.copyWith(selectedStudyIds: updatedSelection);
  }

  void confirmDeleteSelectedStudies() {
    final selectedCount = state.selectedStudyIds.length;
    if (selectedCount == 0) {
      return;
    }

    _notificationService.show(
      AlertIntent(
        title: 'Delete selected studies?'.hardcoded,
        message:
            'This will permanently delete $selectedCount selected studies.'
                .hardcoded,
        icon: Icons.delete_rounded,
        actions: [NotificationDefaultActions.cancel],
      ),
      actions: [
        NotificationAction(
          label: StudyActionType.delete.string,
          isDestructive: true,
          onSelect: deleteSelectedStudies,
        ),
      ],
    );
  }

  void confirmDuplicateSelectedStudies() {
    final selectedCount = state.selectedStudyIds.length;
    if (selectedCount == 0) {
      return;
    }

    _notificationService.show(
      AlertIntent(
        title: 'Duplicate selected studies?'.hardcoded,
        message:
            'This will create draft copies of $selectedCount selected studies.'
                .hardcoded,
        icon: Icons.file_copy_rounded,
        actions: [NotificationDefaultActions.cancel],
      ),
      actions: [
        NotificationAction(
          label: StudyActionType.duplicate.string,
          onSelect: duplicateSelectedStudies,
        ),
      ],
    );
  }

  Future<void> deleteSelectedStudies() async {
    final selectedIds = [...state.selectedStudyIds];
    if (selectedIds.isEmpty) {
      return;
    }

    _setBulkActionInProgress(true, totalCount: selectedIds.length);
    try {
      final studies = state.studies.value ?? const <Study>[];
      final studyTitlesById = {
        for (final study in studies)
          study.id: (study.title ?? 'Untitled study'.hardcoded),
      };
      final deletedIds = <String>{};
      final failedStudies = <({String title, String reason})>[];

      for (final studyId in selectedIds) {
        try {
          await _studyRepository.deletePersisted(studyId);
          deletedIds.add(studyId);
        } catch (error) {
          final reason = _describeDeleteError(error);
          failedStudies.add(
            (
              title:
                  studyTitlesById[studyId] ?? 'Study $studyId'.hardcoded,
              reason: reason,
            ),
          );
        } finally {
          _advanceBulkActionProgress();
        }
      }

      final refreshedStudies = await _studyRepository.fetchAll();
      final remainingIds = refreshedStudies.map((wrapped) => wrapped.model.id).toSet();
      final verifiedDeletedIds = deletedIds.where((id) => !remainingIds.contains(id)).toSet();
      final unverifiedDeletedIds = deletedIds.difference(verifiedDeletedIds);
      for (final studyId in unverifiedDeletedIds) {
        failedStudies.add(
          (
            title: studyTitlesById[studyId] ?? 'Study $studyId'.hardcoded,
            reason:
                'Deletion was requested but the study still exists after refresh.'
                    .hardcoded,
          ),
        );
      }

      final remainingSelection = {...state.selectedStudyIds}
        ..removeAll(verifiedDeletedIds);
      state = state.copyWith(selectedStudyIds: remainingSelection);

      if (failedStudies.isEmpty) {
        _notificationService.showMessage(
          'Deleted ${verifiedDeletedIds.length} studies.'.hardcoded,
        );
        return;
      }

      if (verifiedDeletedIds.isEmpty) {
        _notificationService.show(
          AlertIntent(
            title: 'Delete failed'.hardcoded,
            customContent: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'None of the selected studies could be deleted.'
                        .hardcoded,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Failed deletions'.hardcoded,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final study in failedStudies)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                              ),
                              title: Text(study.title, maxLines: 2),
                              subtitle: Text(
                                study.reason,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            icon: Icons.delete_rounded,
            actions: [NotificationDefaultActions.cancel],
          ),
        );
        return;
      }

      _notificationService.show(
        AlertIntent(
          title: 'Delete completed with issues'.hardcoded,
          customContent: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deleted ${verifiedDeletedIds.length} studies. ${failedStudies.length} could not be deleted.'
                      .hardcoded,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Failed deletions'.hardcoded,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final study in failedStudies)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red,
                            ),
                            title: Text(study.title, maxLines: 2),
                            subtitle: Text(
                              study.reason,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          icon: Icons.delete_rounded,
          actions: [NotificationDefaultActions.cancel],
        ),
      );
    } finally {
      _setBulkActionInProgress(false);
    }
  }

  Future<void> duplicateSelectedStudies() async {
    final selectedIds = state.selectedStudyIds;
    if (selectedIds.isEmpty) {
      return;
    }

    _setBulkActionInProgress(true, totalCount: selectedIds.length);
    try {
      final studies = state.studies.value ?? const <Study>[];
      final selectedStudies = studies
          .where((study) => selectedIds.contains(study.id))
          .toList();

      final duplicatedIds = <String>{};
      final failedIds = <String>{};

      for (final study in selectedStudies) {
        try {
          await _studyRepository.duplicateAndSavePersisted(study);
          duplicatedIds.add(study.id);
        } catch (_) {
          failedIds.add(study.id);
        } finally {
          _advanceBulkActionProgress();
        }
      }

      await _studyRepository.fetchAll();

      if (failedIds.isEmpty) {
        _notificationService.showMessage(
          'Created ${duplicatedIds.length} study copies.'.hardcoded,
        );
        return;
      }

      if (duplicatedIds.isEmpty) {
        _notificationService.showMessage(
          'Could not duplicate the selected studies.'.hardcoded,
        );
        return;
      }

      _notificationService.showMessage(
        'Created ${duplicatedIds.length} study copies. ${failedIds.length} failed.'
            .hardcoded,
      );
    } finally {
      _setBulkActionInProgress(false);
    }
  }

  Future<void> exportSelectedStudies() async {
    final selectedIds = state.selectedStudyIds;
    if (selectedIds.isEmpty) {
      return;
    }

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      return;
    }

    _setBulkActionInProgress(true, totalCount: selectedIds.length);
    try {
      final exportedIds = <String>{};
      final failedIds = <String>{};
      final skippedStudies = <({String title, String reason})>[];
      final failedStudies = <({String title, String reason})>[];

      for (final studyId in selectedIds) {
        try {
          developer.log(
            'Fetching full study for export: $studyId',
            name: 'DashboardController.bulkExport',
          );
          final study = (await _studyRepository.fetch(studyId)).model;

          developer.log(
            'Fetched full study ${study.id} (${study.title}); participants=${study.participants?.length ?? 0}, progress=${study.participantsProgress?.length ?? 0}',
            name: 'DashboardController.bulkExport',
          );

          if (!study.canExport(currentUser)) {
            final reason =
                study.exportDisabledReason(currentUser) ??
                'Export is unavailable.'.hardcoded;
            skippedStudies.add(
              (
                title: study.title ?? 'Untitled study'.hardcoded,
                reason: reason,
              ),
            );
            developer.log(
              'Bulk export skipped study ${study.id} (${study.title}) because export is unavailable: $reason',
              name: 'DashboardController.bulkExport',
            );
            continue;
          }

          developer.log(
            'Starting export for study ${study.id} (${study.title})',
            name: 'DashboardController.bulkExport',
          );
          await study.exportData.downloadAsZip();
          exportedIds.add(study.id);
          developer.log(
            'Export completed for study ${study.id} (${study.title})',
            name: 'DashboardController.bulkExport',
          );
        } catch (error, stackTrace) {
          failedIds.add(studyId);
          failedStudies.add(
            (
              title: 'Study $studyId'.hardcoded,
              reason: 'Export failed due to an unexpected error.'.hardcoded,
            ),
          );
          developer.log(
            'Export failed for study $studyId: $error',
            name: 'DashboardController.bulkExport',
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          _advanceBulkActionProgress();
        }
      }

      if (failedIds.isEmpty && skippedStudies.isEmpty) {
        _notificationService.showMessage(
          'Started export for ${exportedIds.length} studies.'.hardcoded,
        );
        return;
      }

      final summary = <String>[];
      if (exportedIds.isNotEmpty) {
        summary.add(
          'Started export for ${exportedIds.length} studies.'.hardcoded,
        );
      }
      if (skippedStudies.isNotEmpty) {
        summary.add(
          '${skippedStudies.length} studies could not be exported.'.hardcoded,
        );
      }
      if (failedIds.isNotEmpty) {
        summary.add('${failedIds.length} failed during export.'.hardcoded);
      }

      _notificationService.show(
        AlertIntent(
          title: 'Export completed with issues'.hardcoded,
          customContent: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.join(' ')),
                if (skippedStudies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Not exported'.hardcoded,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final study in skippedStudies)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.deepOrange,
                              ),
                              title: Text(study.title, maxLines: 2),
                              subtitle: Text(
                                study.reason,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (failedStudies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Failed'.hardcoded,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      for (final study in failedStudies)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                          ),
                          title: Text(study.title, maxLines: 2),
                          subtitle: Text(
                            study.reason,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          icon: Icons.download_rounded,
          actions: [NotificationDefaultActions.cancel],
        ),
      );
    } finally {
      _setBulkActionInProgress(false);
    }
  }

  String _describeDeleteError(Object error) {
    if (error case APIException apiError) {
      if (apiError.statusCode == '409' || apiError.statusCode == '23503') {
        return _describeDeleteConflict(apiError);
      }
      if (apiError.message != null && apiError.message!.trim().isNotEmpty) {
        final message = apiError.message!.trim();
        if (_looksLikeInviteConflict(message)) {
          return 'This study still has invite codes linked to it. Delete the invite codes first, then delete the study.'
              .hardcoded;
        }
        return message.hardcoded;
      }
    }

    final raw = error.toString();
    if (_looksLikeInviteConflict(raw)) {
      return 'This study still has invite codes linked to it. Delete the invite codes first, then delete the study.'
          .hardcoded;
    }
    if (raw.contains('23503')) {
      return 'This study cannot be deleted because other data still references it.'
          .hardcoded;
    }
    return 'Could not delete this study because the server rejected the request.'
        .hardcoded;
  }

  bool _looksLikeInviteConflict(String text) {
    return text.contains('study_invite_studyId_fkey') ||
        text.contains('study_invite') ||
        text.contains('invite code') ||
        text.contains('Key is still referenced from table "study_invite"');
  }

  String _describeDeleteConflict(APIException error) {
    final detail = error.details?.toString().trim();
    final message = error.message?.trim();

    if (_looksLikeInviteConflict(message ?? '') ||
        _looksLikeInviteConflict(detail ?? '')) {
      return 'This study still has invite codes linked to it. Delete the invite codes first, then delete the study.'
          .hardcoded;
    }

    if (detail != null && detail.isNotEmpty && detail != 'null') {
      return detail.hardcoded;
    }
    if (message != null && message.isNotEmpty) {
      return message.hardcoded;
    }
    return 'The server reported a conflict while deleting this study. Dependent data may still reference it.'
        .hardcoded;
  }

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state = state.copyWith(
      sortByColumn: sortByColumn,
      sortAscending: ascending,
    );
  }

  Future<void> filterStudies(String? query) async {
    state = state.copyWith(query: query);
  }

  Future<void> sortStudies() async {
    final studies = state.sort(
      pinnedStudies: _userRepository.user.preferences.pinnedStudies,
    );
    state = state.copyWith(studies: () => AsyncValue.data(studies));
  }

  bool isSortingActiveForColumn(StudiesTableColumn column) {
    return state.sortByColumn == column;
  }

  bool isSortAscending() {
    return state.sortAscending;
  }

  bool isPinned(Study study) {
    return _userRepository.user.preferences.pinnedStudies.contains(study.id);
  }

  @override
  List<ModelAction> availableActions(Study model) {
    final pinActions = [
      ModelAction(
        type: StudyActionType.pin,
        label: StudyActionType.pin.string,
        onExecute: () async {
          await pinStudy(model.id);
        },
        isAvailable: !isPinned(model),
      ),
      ModelAction(
        type: StudyActionType.pinoff,
        label: StudyActionType.pinoff.string,
        onExecute: () async {
          await pinOffStudy(model.id);
        },
        isAvailable: isPinned(model),
      ),
    ].where((action) => action.isAvailable).toList();

    final studyActions = _studyRepository
        .availableActions(model)
        .where((action) => action.type != StudyActionType.exportDefinition)
        .toList();

    return withIcons([...pinActions, ...studyActions], studyActionIcons);
  }
}
