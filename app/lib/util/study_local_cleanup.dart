import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Future<StudySubject?> resolveCachedSubjectForCleanup({
  StudySubject? fallbackSubject,
}) async {
  try {
    return await Cache.loadSubject(backupSubject: fallbackSubject);
  } catch (_) {
    return fallbackSubject;
  }
}

Future<void> clearStudyLocalData({
  StudySubject? fallbackSubject,
  bool clearStoredParticipantCredentials = false,
}) async {
  final subject = await resolveCachedSubjectForCleanup(
    fallbackSubject: fallbackSubject,
  );
  await Cache.deletePendingBlobFilesForSubject(subject);
  if (subject != null) {
    await FitbitHandler.deleteFitbitCredentials(subject.studyId);
  }
  await clearDeletedSubjectLocalState();
  if (clearStoredParticipantCredentials) {
    await clearParticipantCredentials();
  }
}
