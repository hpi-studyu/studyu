import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Preview {
  final Map<String, String> queryParameters;
  Study study;
  String selectedStudyObjectId;
  StudySubject subject;

  Preview(this.queryParameters);

  Future init() async {
    selectedStudyObjectId = await getActiveSubjectId();
  }

  Future<bool> handleAuthorization() async {
    if (!containsQuery('studyid') && !containsQuery('session')) return false;

    final String session = Uri.decodeComponent(queryParameters['session']);
    final recovery = await Supabase.instance.client.auth.recoverSession(session,);
    if (recovery.error != null) return false;

    study = await SupabaseQuery.getById<Study>(queryParameters['studyid']);
    // todo are results visible for published studies inside preview?
    if (study == null) return false;

    return true;
  }

  Future<void> runCommands() async {
    // delete study subscription and progress
    if (containsQueryPair('cmd', 'reset')) {
      if (selectedStudyObjectId != null) {
        final StudySubject subject =
        await SupabaseQuery.getById<StudySubject>(
          selectedStudyObjectId,
          selectedColumns: [
            '*',
            'study!study_subject_studyId_fkey(*)',
            'subject_progress(*)',
          ],
        );
        subject.delete();
        deleteActiveStudyReference();
        selectedStudyObjectId = await getActiveSubjectId();
        assert (selectedStudyObjectId == null);
      }
    }
  }

  Future<bool> isSubscribed() async {
    if (selectedStudyObjectId != null) {
      subject = await SupabaseQuery.getById<StudySubject>(
        selectedStudyObjectId,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*)',
          'subject_progress(*)',
        ],
      );
      if (subject.studyId == study.id) {
        // user is already subscribed to a study
        return true;
      }
    }
    return false;
  }

  bool containsQuery(String key) {
    return queryParameters.containsKey(key) && queryParameters[key].isNotEmpty;
  }

  bool containsQueryPair(String key, String value) {
    return queryParameters.containsKey(key) && queryParameters[key] == value;
  }
}
