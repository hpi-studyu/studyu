import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/notifications.dart';
import 'preview.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionString;
  final Map<String, String> queryParameters;

  const LoadingScreen({Key key, this.sessionString, this.queryParameters}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    /*
    final hasRecovered = await recoverSupabaseSession();
    if (!hasRecovered)
      await Supabase.instance.client.auth.recoverSession(widget.sessionString);
    if (widget.sessionString == null)
      initStudy();
    */
    if (widget.sessionString != null && widget.sessionString.isNotEmpty && Supabase.instance.client.auth.currentSession == null) {
      // print("recover session");
      await Supabase.instance.client.auth.recoverSession(widget.sessionString);
    }
    if (widget.sessionString == null) {
      // print("initstudy");
      initStudy();
    }
  }

  Future<void> initStudy() async {
    final state = context.read<AppState>();
    final preview = Preview(
      widget.queryParameters ?? {},
      context.read<AppLanguage>(),
    );

    // print("[PreviewApp]: InitStudy called: " + widget.queryParameters.toString());

    if (preview.containsQueryPair('mode', 'preview')) {
      final iFrameHelper = IFrameHelper();
      state.isPreview = true;
      await preview.init();

      // Authorize
      if (!await preview.handleAuthorization()) {
        // print('[PreviewApp]: Preview authorization error');
        return;
      }
      state.selectedStudy = preview.study;

      await preview.runCommands();

      iFrameHelper.listen(state);

      if (preview.hasRoute()) {
        // print('[PreviewApp]: Found preview route:: ${preview.selectedRoute}');

        // ELIGIBILITY CHECK
        if (preview.selectedRoute == '/eligibilityCheck') {
          if (!mounted) return;
          // if we remove the await, we can push multiple times. warning: do not run in while(true)
          await Navigator.push<EligibilityResult>(context, EligibilityScreen.routeFor(study: preview.study));
          // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
          iFrameHelper.postRouteFinished();
          return;
        }

        // INTERVENTION SELECTION
        if (preview.selectedRoute == Routes.interventionSelection) {
          if (!mounted) return;
          await Navigator.pushNamed(context, Routes.interventionSelection);
          iFrameHelper.postRouteFinished();
          return;
        }

        state.activeSubject = await preview.getStudySubject(state, createSubject: true);

        // CONSENT
        if (preview.selectedRoute == Routes.consent) {
          if (!mounted) return;
          await Navigator.pushNamed<bool>(context, Routes.consent);
          iFrameHelper.postRouteFinished();
          return;
        }

        // JOURNEY
        if (preview.selectedRoute == Routes.journey) {
          if (!mounted) return;
          await Navigator.pushNamed(context, Routes.journey);
          iFrameHelper.postRouteFinished();
          return;
        }

        // DASHBOARD
        if (preview.selectedRoute == Routes.dashboard) {
          if (!mounted) return;
          await Navigator.pushReplacementNamed(context, Routes.dashboard);
          iFrameHelper.postRouteFinished();
          return;
        }

        // INTERVENTION [i]
        if (preview.selectedRoute == '/intervention') {
          // todo not sure which includeBaseline statement is needed.
          // todo Either one of here or in preview.createFakeSubject
          // todo maybe remove
          state.selectedStudy.schedule.includeBaseline = false;
          state.activeSubject.study.schedule.includeBaseline = false;
          // print("[PreviewApp]: Route preview");
          if (!mounted) return;
          // print("[PreviewApp]: Go to dashboard");
          await Navigator.pushReplacementNamed(context, Routes.dashboard);
          iFrameHelper.postRouteFinished();
          return;
        }

        // OBSERVATION [i]
        if (preview.selectedRoute == '/observation') {
          print(state.selectedStudy.observations.first.id);
          final tasks = <Task>[
            ...state.selectedStudy.observations.where((observation) => observation.id == preview.extra),
          ];
          if (!mounted) return;
          await Navigator.push<bool>(context, TaskScreen.routeFor(task: tasks.first));
          iFrameHelper.postRouteFinished();
          return;
        }
      } else {
        // print("[PreviewApp]: Found no preview route");
        if (isUserLoggedIn()) {
          final subject = await preview.getStudySubject(state);
          if (subject != null) {
            state.activeSubject = subject;
            // print("[PreviewApp]: push to dashboard1");
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, Routes.dashboard);
            return;
          } else {
            // print("[PreviewApp]: Go to overview");
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, Routes.studyOverview);
            return;
          }
        } else {
          // print("[PreviewApp]: Go to welcome1");
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, Routes.welcome);
          return;
        }
      }
    } // finish preview

    // print("No preview");
    if (!mounted) return;
    if (context.read<AppState>().isPreview) {
      previewSubjectIdKey();
    }

    // todo temp debug
    //await storeFakeUserEmailAndPassword('a2a04eae-70ee-47d7-875b-22fb3e191073@fake-studyu-email-domain.com', "f7ec7b54-f59c-4ab4-aa89-2c34265cb63b");
    //signInParticipant();
    //await storeActiveSubjectId("dabb4a04-77a0-44ff-b82a-389f059410f3");

    final selectedStudyObjectId = await getActiveSubjectId();
    print('Selected study: $selectedStudyObjectId');
/*
    try {
     final test =
      // await SupabaseClient('https://rzxnjlfzycwnaayubbeo.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6eG5qbGZ6eWN3bmFheXViYmVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTY1MTM1MTcsImV4cCI6MTk3MjA4OTUxN30.OGqe_zCQIUImHc5YwN5S0PljMTdhT4Jtb8VK9eGtE-4')
      await Supabase.instance.client
          .from('study_subject')
          .select('*, study!study_subject_studyId_fkey(*), subject_progress(*)')
          .eq('id', selectedStudyObjectId)
          .single();
          //.select<List<Map<String, dynamic>>>();
          //.select<Map<String, dynamic>>();
      /*    subject = await SupabaseQuery.getById<StudySubject>(
        selectedStudyObjectId,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*)',
          'subject_progress(*)',
        ],
      );*/
      print("test3: " + test.toString());
    } catch(e) {
      print("ERROR: " + e.toString());
    }
    exit(1);*/
    if (!mounted) return;
    if (selectedStudyObjectId == null) {
      if (isUserLoggedIn()) {
        // print("Go to study selection");
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
      // print("Go to welcome2");
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }
    StudySubject subject;
    try {
      subject = await SupabaseQuery.getById<StudySubject>(
        selectedStudyObjectId,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*)',
          'subject_progress(*)',
        ],
      );
    } catch (e) {
      print("Try signing in again $e");
      try {
        // Try signing in again. Needed if JWT is expired
        await signInParticipant();
        subject = await SupabaseQuery.getById<StudySubject>(
          selectedStudyObjectId,
          selectedColumns: [
            '*',
            'study!study_subject_studyId_fkey(*)',
            'subject_progress(*)',
          ],
        );
      } catch (e) {
        print('Error when trying to login and retrieve the study subject');
      }
    }
    if (!mounted) return;

    if (subject != null) {
      // print("Subject: " + subject.toString()); // todo remove me
      state.activeSubject = subject;
      if (!kIsWeb) {
        // Notifications not supported on web
        scheduleStudyNotifications(context);
      }
      // print("push to dashboard2");
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      // print("push to welcome3");
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations
                    .of(context)
                    .loading}...',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
