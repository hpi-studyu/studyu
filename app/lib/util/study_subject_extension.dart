import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart'
    as flutter_common;

@visibleForTesting
Future<SubjectProgress> Function(SubjectProgress progress)?
debugSaveResultProgressOverride;

@visibleForTesting
Future<StudySubject> Function(StudySubject subject)?
debugSaveResultSubjectOverride;

@visibleForTesting
Future<void> saveResultProgress({
  required StudySubject subject,
  required SubjectProgress progressEntry,
  required Future<SubjectProgress> Function(SubjectProgress progress)
  saveProgress,
  required Future<void> Function() saveSubject,
}) async {
  progressEntry.completedAt ??= DateTime.now().toUtc();
  SubjectProgress savedProgress;
  try {
    savedProgress = await saveProgress(progressEntry);
  } catch (_) {
    if (!subject.progress.contains(progressEntry)) {
      subject.progress.add(progressEntry);
    }
    rethrow;
  }
  if (!subject.progress.contains(savedProgress)) {
    subject.progress.add(savedProgress);
  }
  await saveSubject();
}

extension StudySubjectExtension on StudySubject {
  Future<void> addResult<T>({
    required String taskId,
    required String interventionId,
    required String periodId,
    required T result,
    bool offline = false,
  }) async {
    final Result<T> resultObject = switch (result) {
      QuestionnaireState() => Result<T>.app(
        type: 'QuestionnaireState',
        periodId: periodId,
        result: result,
      ),
      bool() => Result<T>.app(type: 'bool', periodId: periodId, result: result),
      _ => Result<T>.app(type: 'unknown', periodId: periodId, result: result),
    };

    if (resultObject.type == 'unknown') {
      print('Unsupported question type: $T');
    }

    final saveOffline = offline || flutter_common.hasDegradedConnectionStatus();
    final initialProgressCount = progress.length;
    final progressEntry = SubjectProgress(
      subjectId: id,
      interventionId: interventionId,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );

    Future<void> moveQuestionnaireFiles() async {
      if (kIsWeb || resultObject.result is! QuestionnaireState) return;
      final questionnaireState = resultObject.result as QuestionnaireState;
      for (final answerEntry in questionnaireState.answers.entries.toList()) {
        final answer = answerEntry.value;
        if (answer.response is! FutureBlobFile) continue;
        final futureBlobFile = answer.response as FutureBlobFile;
        await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
          futureBlobFile.localFilePath,
          futureBlobFile.futureBlobId,
        );

        // Replaces Answer<FutureBlobFile> with Answer<String>
        questionnaireState.answers[answerEntry.key] = Answer<String>(
          answer.question,
          answer.timestamp,
        )..response = futureBlobFile.futureBlobId;
      }
    }

    try {
      if (saveOffline) {
        await moveQuestionnaireFiles();
        progressEntry.completedAt = DateTime.now().toUtc();
        progress.add(progressEntry);
      } else {
        await Cache.runSubjectRemoteMutation(() async {
          await moveQuestionnaireFiles();
          if (!kIsWeb) {
            await Cache.uploadBlobFiles(studyId, userId);
          }
          await saveResultProgress(
            subject: this,
            progressEntry: progressEntry,
            saveProgress:
                debugSaveResultProgressOverride ??
                (progress) => progress.save(),
            saveSubject: () async {
              final saveSubjectOverride = debugSaveResultSubjectOverride;
              if (saveSubjectOverride != null) {
                await saveSubjectOverride(this);
              } else {
                await save(onlyUpdate: true);
              }
            },
          );
        });
      }
    } catch (_) {
      if (!saveOffline && progress.length == initialProgressCount) {
        progressEntry.completedAt ??= DateTime.now().toUtc();
        progress.add(progressEntry);
      }
      rethrow;
    }
  }
}
