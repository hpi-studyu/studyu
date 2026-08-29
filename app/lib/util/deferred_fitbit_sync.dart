import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

Future<void> persistDeferredFitbitQuestionnaireResult({
  required StudySubject subject,
  required QuestionnaireTask task,
  required String interventionId,
  required String periodId,
  required QuestionnaireState questionnaireState,
  DateTime? completedAt,
}) async {
  await prepareQuestionnaireForLocalPersistence(questionnaireState);
  final request = await FitbitHandler.createDeferredRequest(
    subject: subject,
    task: task,
    interventionId: interventionId,
    periodId: periodId,
    questionnaireState: questionnaireState,
    completedAt: completedAt,
  );
  await Cache.storeDeferredFitbitRequest(request);
  final alreadyCompleted = subject.progress.any(
    (progress) =>
        progress.interventionId == interventionId &&
        progress.taskId == task.id &&
        progress.result.periodId == periodId &&
        progress.completedAt?.toUtc() == request.completedAt,
  );
  if (!alreadyCompleted) {
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: interventionId,
        taskId: task.id,
        resultType: 'QuestionnaireState',
        result: Result<QuestionnaireState>.app(
          type: 'QuestionnaireState',
          periodId: periodId,
          result: questionnaireState,
        ),
      )..completedAt = request.completedAt,
    );
  }
  await Cache.storeSubject(subject);
}
