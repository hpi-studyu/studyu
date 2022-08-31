import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Preview {
  final Map<String, String> queryParameters;
  String selectedRoute;
  String extra;
  bool hasRoute() => selectedRoute != null && selectedRoute.isNotEmpty;
  Study study;
  String selectedStudyObjectId;
  StudySubject subject;

  Preview(this.queryParameters) { handleQueries(); }

  void handleQueries() {
    selectedRoute = getSelectedRoute();
    extra = queryParameters['extra'];
  }

  Future init() async {
    previewSubjectIdKey();
    selectedStudyObjectId = await getActiveSubjectId();
  }

  Future<bool> handleAuthorization() async {
    if (!containsQuery('studyid') && !containsQuery('session')) return false;

    final String session = Uri.decodeComponent(queryParameters['session']);
    final recovery = await Supabase.instance.client.auth.recoverSession(session,);
    if (recovery.error != null) return false;

    if (containsQuery('data')) {
      final data = jsonDecode(queryParameters['data']) as Map<String, dynamic>;
      study = Study.fromJson(data);
    } else {
      study = await SupabaseQuery.getById<Study>(queryParameters['studyid']);
    }
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
      }
    }
  }

  String getSelectedRoute() {
    // check if route is allowed and can be handled
    for (final k in queryParameters.keys) {
      if('route' == k) {
        switch (queryParameters[k]) {
          case 'consent':
            return Routes.consent;
          case 'eligibilityCheck': // this should include questionnaire and eligibility_criteria
            return '/eligibilityCheck';
          case 'interventionSelection':
            return Routes.interventionSelection;
          case 'questionnaire':
            return Routes.questionnaire;
          case 'dashboard':
            return Routes.dashboard;
          case 'intervention':
            return '/intervention';
          case 'observation':
            return '/observation';
        }
      }
    }
    return null;
  }

  bool containsQuery(String key) {
    return queryParameters.containsKey(key) && queryParameters[key].isNotEmpty;
  }

  bool containsQueryPair(String key, String value) {
    return queryParameters.containsKey(key) && queryParameters[key] == value;
  }

  Future<StudySubject> getActiveSubject(AppState state, [String extra]) async {
    subject = await _fetchSubject(state, extra);
    if (selectedRoute == '/intervention') {
      print("disable base 2");
      // todo might be unnecessary if we have study.schedule.includeBaseline = false;
      subject.study.schedule.includeBaseline = false;
    }
    return subject;
  }

  Future<StudySubject> _fetchSubject(AppState state, [String extra]) async {
    try {
      if (selectedStudyObjectId != null) {
        if (selectedRoute == '/intervention') {
          final List<StudySubject> studySubjects = await SupabaseQuery.getAll<StudySubject>(
            selectedColumns: [
              '*',
              'study!study_subject_studyId_fkey(*)',
              'subject_progress(*)',
            ],
          );
          // If the user has a study object Id, there was already a subject created
          // and we need to find the last one they created for the study
          // with the correct interventions
          subject = studySubjects.lastWhere(
                (foundSubject) {
                  foundSubject.study.schedule.includeBaseline = false;
                  return foundSubject.userId == Supabase.instance.client.auth.currentUser.id
                      && foundSubject.studyId == study.id
                      && listEquals(foundSubject.selectedInterventions
                          .map((i) => i.id).toList(), getInterventionIds(),);
                },
          );
          // We switch the currently selected study subject with the one we found
          // that has fitting interventions in the correct order
          // Therefore, we get different subject entries for different interventions
          selectedStudyObjectId = subject.id;
          await storeActiveSubjectId(selectedStudyObjectId);
          // User is already subscribed to a study
          return subject;
        }
        subject = await SupabaseQuery.getById<StudySubject>(
          selectedStudyObjectId,
          selectedColumns: [
            '*',
            'study!study_subject_studyId_fkey(*)',
            'subject_progress(*)',
          ],
        );
        if (subject != null && subject.studyId == study.id) {
          // User is already subscribed to the study
          return subject;
        }
      }
    } catch (e) {
      print('[PreviewApp]: Failed fetching subject: $e');
    }
    // Create a new study subject
    return _createFakeSubject(state, extra);
  }

  Future<StudySubject> _createFakeSubject(AppState state, [String extra]) async {
    if (selectedRoute == '/intervention') {
      // todo maybe remove
      study.schedule.includeBaseline = false;
    }
    subject = StudySubject.fromStudy(
      study,
      Supabase.instance.client.auth.user().id,
      getInterventionIds(),
      null, // no invite code
    );
    subject.startedAt = DateTime.now();

    if (state.trackParticipantProgress) {
      print("[PreviewApp]: Tracking Participant progress");
      try {
        subject = await subject.save();
        await storeActiveSubjectId(subject.id);
        print("[PreviewApp]: Saved subject");
      } catch (e) {
        print('[PreviewApp]: Failed creating subject: $e');
      }
    }
    return subject;
  }

  List<String> getInterventionIds() {
    final interventionList = study.interventions.map((i) => i.id).toList();
    List<String> newInterventionList = [];
    // If we have a specific intervention we want to show, select that and another one
    if (selectedRoute == '/intervention' && extra != null) {
      final String intId = interventionList.firstWhere((id) => id == extra);
      newInterventionList..add(intId)..add(
        interventionList.firstWhere((id) => id != intId),
      );
      assert (newInterventionList.length == 2);
    } else {
      // just take the first two
      newInterventionList = interventionList.sublist(0, 2);
    }
    return newInterventionList;
  }
}
