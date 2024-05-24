import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

import 'cache.dart';

extension StudySubjectExtension on StudySubject {
  Future<void> addResult<T>({
    required String taskId,
    required String periodId,
    required T result,
    bool offline = false,
  }) async {
    final Result<T> resultObject = switch (result) {
      QuestionnaireState() => Result<T>.app(type: 'QuestionnaireState', periodId: periodId, result: result),
      bool() => Result<T>.app(type: 'bool', periodId: periodId, result: result),
      _ => Result<T>.app(type: 'unknown', periodId: periodId, result: result),
    };

    if (resultObject.type == 'unknown') {
      print('Unsupported question type: $T');
    }

    // Skip multimodal file handling for web
    if (!kIsWeb) {
      // Move multimodal files to upload directory
      if (resultObject.result is QuestionnaireState) {
        final questionnaireState = resultObject.result as QuestionnaireState;
        for (final answerEntry in questionnaireState.answers.entries.toList()) {
          final answer = answerEntry.value;
          if (answer.response is FutureBlobFile) {
            final futureBlobFile = answer.response as FutureBlobFile;
            await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
                futureBlobFile.localFilePath, futureBlobFile.futureBlobId);

            // Replaces Answer<FutureBlobFile> with Answer<String>
            questionnaireState.answers[answerEntry.key] = Answer<String>(answer.question, answer.timestamp)
              ..response = futureBlobFile.futureBlobId;
          }
        }
      }
      // Upload multimodal files
      if (!offline) {
        await Cache.uploadBlobFiles();
      }
    }

    SubjectProgress p = SubjectProgress(
      subjectId: id,
      interventionId: getInterventionForDate(DateTime.now())!.id,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );
    if (offline) {
      p.completedAt = DateTime.now().toUtc();
      progress.add(p);
    } else {
      p = await p.save();
      progress.add(p);
      await save(onlyUpdate: true);
    }
  }
}
