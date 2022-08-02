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
    //print('study object preview: $selectedStudyObjectId');
  }

  Future<bool> handleAuthorization() async {
    if (!containsQuery('studyid') && !containsQuery('session')) return false;

    final String session = Uri.decodeComponent(queryParameters['session']);
    final recovery = await Supabase.instance.client.auth.recoverSession(session,);
    if (recovery.error != null) return false;

    study = await SupabaseQuery.getById<Study>(queryParameters['studyid']);
    // todo allow preview for published studies? Are results visible?
    if (study == null) return false;

    return true;
  }

  Future<void> runCommands() async {
    // delete study subscription and progress
    if (containsQueryPair('cmd', 'reset')) {
      // deleting study progress
      //print('subject id: $selectedStudyObjectId');
      if (selectedStudyObjectId != null) {
       // try {
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
        //print('successfully deleted');
        selectedStudyObjectId = await getActiveSubjectId();
        //print('study object after deletion: $selectedStudyObjectId');
        assert (selectedStudyObjectId == null);
          //selectedStudyObjectId = null;
          //print("study object this: " + selectedStudyObjectId);
        /*} catch (e) {
          print('error with deleting: $e');
        }*/
      }
    }
  }

  Future<bool> isSubscribed() async {
    if (selectedStudyObjectId != null) {
      //print('Found subject id in shared prefs: $selectedStudyObjectId');
      // found study subject
      //try {
      subject = await SupabaseQuery.getById<StudySubject>(
        selectedStudyObjectId,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*)',
          'subject_progress(*)',
        ],
      );
      //print('equal check: ${subject.studyId} ${study.id}');
      if (subject.studyId == study.id) {
        // user is already subscribed to a study
        return true;
      }
      /*} catch (e) {
        print('could not load subject id');
      }*/
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
