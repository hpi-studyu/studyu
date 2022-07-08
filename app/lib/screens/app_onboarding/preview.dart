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
    print('init study object: $selectedStudyObjectId');
  }

  Future<bool> handleAuthorization() async {
    if (!containsQuery('studyid') && !containsQuery('session')) return false;

    final String session = Uri.decodeComponent(queryParameters['session']);
    final recovery = await Supabase.instance.client.auth.recoverSession(session);
    if (recovery.error != null) return false;

    study = await SupabaseQuery.getById<Study>(queryParameters['studyid']);
    // todo allow preview for published studies? Are results visible?
    if (study == null) return false;

    return true;
  }

  Future<void> runCommands() async {
    // delete study subscription and progress
    if (containsQueryPair('cmd', 'reset')) {
      //print('subject id: $selectedStudyObjectId');
      if (selectedStudyObjectId != null) {
        print('reset do');
        try {
        subject = await SupabaseQuery.getById<StudySubject>(
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
        print('after deletion: $selectedStudyObjectId');
        selectedStudyObjectId = null; // should normally be updated automatically?
        print('successfully deleted');
        } catch (e) {
          print('error with deleting: $e');
        }
        print('reset completed');
      }
      print('reset finish');
    }
  }

  Future<bool> isSubscribed() async {
    if (selectedStudyObjectId != null) {
      print('Found subject id in shared prefs: $selectedStudyObjectId');
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
      // user is already subscribed to a study
      print('equal check: ${subject.studyId} ${study.id}');
      if (subject.studyId == study.id) {
        return true;
      }
      //} catch (e) {
        //print('could not load subject id');
      //}
    }
    return false;
  }

  bool containsQuery(String key) {
    if (queryParameters.containsKey(key) && queryParameters[key].isNotEmpty) {
      return true;
    }
    return false;
  }

  bool containsQueryPair(String key, String value) {
    if (queryParameters.containsKey(key) && queryParameters[key] == value) {
      return true;
    }
    return false;
  }
}
