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

  /*String identifyRoute() {
    if (hasRoute()) {
      handleRouteRequirements(selectedRoute);
      return selectedRoute;
    }
  }*/

  /*void handleRouteRequirements(String selectedRoute) {


    // interventionSelection,

    //

    /*final appState = context.read<AppState>();
    if (appState.preselectedInterventionIds != null) {
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy,
        Supabase.instance.client.auth.user().id,
        appState.preselectedInterventionIds,
        appState.inviteCode,
      );
      Navigator.pushNamed(context, Routes.journey);
    } else if (study.interventions.length <= 2) {
      // No need to select interventions if there are only 2 or less
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy,
        Supabase.instance.client.auth.user().id,
        study.interventions.map((i) => i.id).toList(),
        appState.inviteCode,
      );
      Navigator.pushNamed(context, Routes.journey);
    } else {
      Navigator.pushNamed(context, Routes.interventionSelection);
    }*/
  }*/

  Future<StudySubject> createFakeSubject() async {
    if (study.interventions.length <= 2) {
      // No need to select interventions if there are only 2 or less
      subject = StudySubject.fromStudy(
        study,
        Supabase.instance.client.auth.user().id,
        study.interventions.map((i) => i.id).toList(),
        null,
      );
    } else {
      // we need to let the user choose interventions
      //Navigator.pushNamed(context, Routes.interventionSelection);
      subject = StudySubject.fromStudy(
        study,
        Supabase.instance.client.auth.user().id,
        // for now just take the first two
        study.interventions.map((i) => i.id).toList().sublist(0, 2),
        null, // no invite code
      );
      subject.startedAt = DateTime.now();
    }
    return subject;
  }
}
