import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
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
    Study exportSource = study;
    try {
      final wrapped = await _studyRepository.fetch(study.id);
      exportSource = wrapped.model;
    } catch (_) {
      // Fallback to the provided study when the full fetch is not available.
    }

    final schema = SimplifiedStudyConverter.toSchema(exportSource);
    final json = prettyJson(schema);
    final filename = '${(exportSource.title ?? 'study').toKey()}_schema'
        .ensureSuffix('.json');
    downloadFile(fileContent: json, filename: filename);
    _notifications.show(Notifications.studyExportSchemaSuccess);
  }

  Future<Study> importStudyFromJson(String rawJson) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      throw const FormatException('No authenticated user available');
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (error) {
      throw FormatException('Invalid study JSON: $error');
    }

    final study = SimplifiedStudyConverter.fromSchema(payload, ownerId: userId);
    final savedWrapped = await _studyRepository.save(study);
    final savedStudy = savedWrapped?.model ?? study;
    
    // Ensure the study is available in the repository by fetching it
    try {
      await _studyRepository.fetch(savedStudy.id);
    } catch (_) {
      // If fetch fails, we'll still proceed with the saved study
      // The UI will handle the race condition with the delay
    }
    
    _notifications.show(Notifications.studyImportSuccess);
    return savedStudy;
  }
}
