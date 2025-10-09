import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/domain/study_protocol_serializer.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

part 'study_repository.g.dart';

abstract class IStudyRepository implements ModelRepository<Study> {
  Future<void> launch(Study study);
  Future<void> deleteParticipants(Study study);
  Future<void> close(Study study);
  Future<void> promptImportStudy();
  // Future<void> deleteProgress(Study study);
}

class StudyRepository extends ModelRepository<Study>
    implements IStudyRepository {
  StudyRepository({
    this.sortCallback,
    required this.apiClient,
    required this.authRepository,
    required this.ref,
  }) : super(
         StudyRepositoryDelegate(
           apiClient: apiClient,
           authRepository: authRepository,
         ),
       );

  /// Reference to the StudyU API injected via Riverpod
  final StudyUApi apiClient;

  /// Reference to the auth repository injected via Riverpod
  final IAuthRepository authRepository;

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  final Ref ref;

  final VoidCallback? sortCallback;

  @override
  ModelID getKey(Study model) {
    return model.id;
  }

  @override
  Future<void> deleteParticipants(Study study) {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final List<StudySubject> participants = [...study.participants ?? []];

    final deleteParticipantsOperation = OptimisticUpdate(
      applyOptimistic: () => study.participants = [],
      apply: () async {
        await apiClient.deleteParticipants(study, participants);
        upsertLocally(study);
      },
      rollback: () => study.participants = participants,
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        get(study.id)?.markWithError(e);
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
      rethrowErrors: true,
    );

    return deleteParticipantsOperation.execute();
  }

  @override
  Future<void> launch(Study study) {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final publishedCopy = study.asNewlyPublished();

    final publishOperation = OptimisticUpdate(
      applyOptimistic: () => {}, // nothing to do here
      apply: () => save(publishedCopy, runOptimistically: false),
      rollback: () {}, // nothing to do here
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
    );

    deleteParticipants(study);
    return publishOperation.execute();
  }

  /// This method fetches the full study object, duplicates it and saves it as a draft.
  /// Since the Study object in the dashboard is fetched with limited columns (no intervention or measurement data),
  /// we need to fetch the full columns in order to duplicate it correctly.
  @override
  Future<void> duplicateAndSave(Study model) async {
    final Study completeModel = await apiClient.fetchStudy(model.id);
    final duplicate = completeModel.duplicateAsDraft(
      authRepository.currentUser!.id,
    );
    await save(duplicate);
  }

  @override
  Future<void> close(Study study) {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }
    study.status = StudyStatus.closed;

    final publishOperation = OptimisticUpdate(
      applyOptimistic: () => {}, // nothing to do here
      apply: () => save(study, runOptimistically: false),
      rollback: () {}, // nothing to do here
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
    );

    return publishOperation.execute();
  }

  @override
  List<ModelAction> availableActions(Study model) {
    Future<void> onDeleteCallback() {
      return delete(model.id)
          .then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          )
          .then(
            (value) => Future.delayed(
              const Duration(milliseconds: 200),
              () => ref
                  .read(notificationServiceProvider)
                  .show(Notifications.studyDeleted),
            ),
          );
    }

    final currentUser = authRepository.currentUser;
    if (currentUser == null) return [];

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: StudyActionType.edit.string,
        onExecute: () {
          ref.read(routerProvider).dispatch(RoutingIntents.studyEdit(model.id));
        },
        isAvailable: model.canEditDraft(currentUser),
      ),
      ModelAction(
        // same as "Copy" but for non-drafts
        type: StudyActionType.duplicateDraft,
        label: StudyActionType.duplicateDraft.string,
        onExecute: () async {
          return await duplicateAndSave(model).then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          );
        },
        isAvailable:
            model.status != StudyStatus.draft && model.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: StudyActionType.duplicate.string,
        onExecute: () async {
          return await duplicateAndSave(model).then(
            (value) =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
          );
        },
        isAvailable:
            model.status == StudyStatus.draft && model.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.exportProtocol,
        label: StudyActionType.exportProtocol.string,
        onExecute: () {
          runAsync(() => _exportStudyProtocol(model));
        },
        isAvailable: model.canEdit(currentUser),
      ),
      /*
      TODO re-implement this properly
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
       */
      ModelAction(
        type: StudyActionType.export,
        label: StudyActionType.export.string,
        onExecute: () {
          runAsync(() => model.exportData.downloadAsZip());
        },
        isAvailable: model.canExport(currentUser),
      ),
      if (model.canDelete(currentUser)) ModelAction.addSeparator(),
      ModelAction(
        type: StudyActionType.delete,
        label: StudyActionType.delete.string,
        onExecute: () {
          return ref
              .read(notificationServiceProvider)
              .show(
                Notifications
                    .studyDeleteConfirmation, // TODO: more severe confirmation for running studies
                actions: [
                  NotificationAction(
                    label: StudyActionType.delete.string,
                    onSelect: onDeleteCallback,
                    isDestructive: true,
                  ),
                ],
              );
        },
        isAvailable: model.canDelete(currentUser),
        isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }

  Future<void> _exportStudyProtocol(Study model) async {
    try {
      final study = await apiClient.fetchStudy(model.id);
      final payload = StudyProtocolSerializer.exportStudy(study);
      final content = StudyProtocolSerializer.encodePretty(payload);
      final filename = '${_slugify(study.title ?? 'study')}_protocol.json'
          .toLowerCase();
      downloadFile(fileContent: content, filename: filename);
      ref
          .read(notificationServiceProvider)
          .show(Notifications.studyProtocolExported);
    } catch (error, stackTrace) {
      emitError(modelStreamControllers[model.id], error, stackTrace);
      ref
          .read(notificationServiceProvider)
          .show(Notifications.studyProtocolExportFailed);
    }
  }

  @override
  Future<void> promptImportStudy() async {
    ref
        .read(notificationServiceProvider)
        .show(
          AlertIntent(
            title: tr.dialog_study_protocol_import_title,
            customContent: _StudyProtocolImportContent(
              description: tr.dialog_study_protocol_import_description,
              hintText: tr.form_field_study_protocol_import_hint,
              onSubmit: _handleImportedProtocol,
            ),
            dismissOnAction: false,
          ),
        );
  }

  Future<String?> _handleImportedProtocol(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return tr.validation_study_protocol_import_empty;
    }

    Study? study;
    try {
      final data = StudyProtocolSerializer.decode(trimmed);
      study = StudyTemplates.emptyDraft(authRepository.currentUser!.id);
      StudyProtocolSerializer.applyToStudy(study, data);
      await save(study, runOptimistically: false);
      ref
          .read(notificationServiceProvider)
          .show(Notifications.studyProtocolImported);
      return null;
    } on FormatException catch (_) {
      return tr.validation_study_protocol_import_invalid;
    } catch (error, stackTrace) {
      emitError(
        study != null ? modelStreamControllers[study.id] : null,
        error,
        stackTrace,
      );
      ref
          .read(notificationServiceProvider)
          .show(Notifications.studyProtocolImportFailed);
      return tr.validation_study_protocol_import_invalid;
    }
  }

  String _slugify(String value) {
    final normalized = value.toLowerCase().trim();
    final sanitized = normalized.replaceAll(RegExp('[^a-z0-9]+'), '-');
    final collapsed = sanitized.replaceAll(RegExp('-{2,}'), '-');
    final trimmed = collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed.isEmpty ? 'study' : trimmed;
  }
}

class _StudyProtocolImportContent extends StatefulWidget {
  const _StudyProtocolImportContent({
    required this.description,
    required this.hintText,
    required this.onSubmit,
  });

  final String description;
  final String hintText;
  final Future<String?> Function(String content) onSubmit;

  @override
  State<_StudyProtocolImportContent> createState() =>
      _StudyProtocolImportContentState();
}

class _StudyProtocolImportContentState
    extends State<_StudyProtocolImportContent> {
  String? _error;
  bool _isSubmitting = false;
  late final TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: TextField(
            controller: _controller,
            maxLines: 12,
            minLines: 6,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              errorText: _error,
              contentPadding: const EdgeInsets.all(12),
            ),
            keyboardType: TextInputType.multiline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).maybePop(),
              child: Text(tr.dialog_cancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _isSubmitting ? null : _onSubmitPressed,
              child: _isSubmitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(tr.action_study_import_protocol),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onSubmitPressed() async {
    setState(() {
      _error = null;
      _isSubmitting = true;
    });
    final result = await widget.onSubmit(_controller.text);
    if (!mounted) return;

    if (result == null) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).maybePop();
    } else {
      setState(() {
        _error = result;
        _isSubmitting = false;
      });
    }
  }
}

class StudyRepositoryDelegate extends IModelRepositoryDelegate<Study> {
  StudyRepositoryDelegate({
    required this.apiClient,
    required this.authRepository,
  });

  final StudyUApi apiClient;
  final IAuthRepository authRepository;

  @override
  Future<List<Study>> fetchAll() {
    return apiClient.getUserStudies(forDashboardDisplay: true);
  }

  @override
  Future<Study> fetch(ModelID modelId) {
    return apiClient.fetchStudy(modelId);
  }

  @override
  Future<Study> save(Study model) {
    return apiClient.saveStudy(model);
  }

  @override
  Future<void> delete(Study model) {
    return apiClient.deleteStudy(model);
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  Study createNewInstance() {
    return StudyTemplates.emptyDraft(authRepository.currentUser!.id);
  }

  @override
  Study createDuplicate(Study model) {
    return model.duplicateAsDraft(authRepository.currentUser!.id);
  }
}

@riverpod
StudyRepository studyRepository(Ref ref) => StudyRepository(
  apiClient: ref.watch(apiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  ref: ref,
);
