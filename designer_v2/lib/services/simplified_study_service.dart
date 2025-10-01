import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/study_export_extension.dart';
import 'package:studyu_designer_v2/domain/simplified_study_converter.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';

final simplifiedStudyServiceProvider = Provider<SimplifiedStudyService>(
  (ref) => SimplifiedStudyService(ref),
);

class SimplifiedStudyService {
  SimplifiedStudyService(this.ref);

  final Ref ref;

  IStudyRepository get _studyRepository => ref.read(studyRepositoryProvider);
  IAuthRepository get _authRepository => ref.read(authRepositoryProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  Future<void> exportStudy(Study study) async {
    final exportSource = await _getExportSource(study);
    final schema = exportSource.toExportSchema();
    final json = prettyJson(schema);
    final filename = _generateExportFilename(exportSource);

    downloadFile(fileContent: json, filename: filename);
    _notifications.show(Notifications.studyExportSchemaSuccess);
  }

  Future<Study> _getExportSource(Study study) async {
    try {
      final wrapped = await _studyRepository.fetch(study.id);
      return wrapped.model;
    } catch (_) {
      return study;
    }
  }

  String _generateExportFilename(Study study) {
    const defaultStudyName = 'study';
    const fileExtension = '.json';
    const schemaSuffix = '_schema';

    return '${(study.title ?? defaultStudyName).toKey()}$schemaSuffix'
        .ensureSuffix(fileExtension);
  }

  Future<Study> importStudyFromJson(String rawJson) async {
    final userId = _validateAuthenticatedUser();
    final payload = _parseJsonPayload(rawJson);

    final study = SimplifiedStudyConverter.fromSchema(payload, ownerId: userId);
    final savedStudy = await _saveAndCacheStudy(study);

    _notifications.show(Notifications.studyImportSuccess);
    return savedStudy;
  }

  String _validateAuthenticatedUser() {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      throw const FormatException('No authenticated user available');
    }
    return userId;
  }

  Map<String, dynamic> _parseJsonPayload(String rawJson) {
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (error) {
      throw FormatException('Invalid study JSON: $error');
    }
  }

  Future<Study> _saveAndCacheStudy(Study study) async {
    final savedWrapped = await _studyRepository.save(study);
    final savedStudy = savedWrapped?.model ?? study;

    // Add delay to allow database propagation before fetching
    await Future.delayed(const Duration(milliseconds: 500));
    await _warmRepositoryCache(savedStudy.id);

    return savedStudy;
  }

  Future<void> _warmRepositoryCache(String studyId) async {
    try {
      await _studyRepository.fetch(studyId);
    } on Exception {
      return;
    }
  }
}
