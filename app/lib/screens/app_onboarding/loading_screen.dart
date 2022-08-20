import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
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

class _LoadingScreenState extends SupabaseAuthState<LoadingScreen> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final hasRecovered = await recoverSupabaseSession();
    if (!hasRecovered) {
      await Supabase.instance.client.auth.recoverSession(widget.sessionString);
    }

    initStudy();
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>();
    final preview = Preview(widget.queryParameters ?? {});

    if (preview.containsQueryPair('mode', 'preview')) {
      model.isPreview = true;
      await preview.init();

      // Authorize
      if (!await preview.handleAuthorization()) return;
      model.selectedStudy = preview.study;

      await preview.runCommands();
      if (preview.hasRoute()) {
        print("has route: " + preview.selectedRoute);

        // ELIGIBILITY CHECK
        if (preview.selectedRoute == '/eligibilityCheck') {
          if (!mounted) return;
            // if we remove the await, we can push multiple times. warning: do not run in while(true)
            final result = await Navigator.push<EligibilityResult>(context, EligibilityScreen.routeFor(study: preview.study));
            //if (!mounted) return;
            //print("STILL MOUNTED");
            // todo either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
            // todo move webcontent to other class
            html.window.parent.postMessage("routeFinished", '*');
            return;
        }

        // INTERVENTION SELECTION
        if (preview.selectedRoute == Routes.interventionSelection) {
          if (!mounted) return;
          final interventionSelected = await Navigator.pushNamed(context, Routes.interventionSelection);
          html.window.parent.postMessage("routeFinished", '*');
          return;
        }

        // CONSENT
        if (preview.selectedRoute == Routes.consent) {
          // user should (must?) not be subscribed to a study to view the consent
          // we need to create a fake activeSubject (and maybe also unsubscribe a user if he is already subscribed)
          model.activeSubject = await preview.createFakeSubject();
          if (!mounted) return;
          //final consentGiven = Navigator.pushReplacementNamed(context, Routes.consent,);
          final consentGiven = await Navigator.pushNamed<bool>(context, Routes.consent);
          html.window.parent.postMessage("routeFinished", '*');
          return;
        }

        // GET SUBJECT
        // check if a study subscription is necessary
        //if (preview.selectedRoute == Routes.dashboard || preview.selectedRoute == Routes.task0) {
        if (await preview.isSubscribed()) {
          model.activeSubject = preview.subject;
        } else {
          model.activeSubject = await preview.createFakeSubject();
          // print(model.activeSubject.toJson().toString());
          // print(model.activeSubject.study.observations.first.toString());
        }

        // DASHBOARD
        if (preview.selectedRoute == Routes.dashboard) {
          if (!mounted) return;
          await Navigator.pushReplacementNamed(context, Routes.dashboard);
          html.window.parent.postMessage("routeFinished", '*');
          return;
        }

        // OBSERVATION [i]
        if (preview.selectedRoute == '/observation') {
          if (!mounted) return;
          // taskId = model.activeSubject.study.observations.first.id
          final tasks = <Task>[
            ...model.selectedStudy.observations.where((observation) => observation.id == preview.extra).toList(),
          ];
          final result = await Navigator.push<TaskScreen>(context, TaskScreen.routeFor(task: tasks.first, taskId: preview.extra));
          //Navigator.pushReplacementNamed(context, Routes.task0);
          html.window.parent.postMessage("routeFinished", '*');
          return;
        }

        // INTERVENTION [i]
        if (preview.selectedRoute == '/intervention') {
          if (!mounted) return;
          final tasks = <Task>[
            ...model.activeSubject.selectedInterventions
                .map((intervention) => intervention.tasks.where((task) => task.id == preview.extra))
                .expand((task) => task)
                .toList()
          ];
          final result = await Navigator.push<TaskScreen>(context, TaskScreen.routeFor(task: tasks.first, taskId: preview.extra));
          html.window.parent.postMessage("routeFinished", '*');
          return;
        }
        //}
      } else {
        if (!mounted) return;
        if (isUserLoggedIn()) {
          Navigator.pushReplacementNamed(context, Routes.studyOverview);
          return;
        }
        Navigator.pushReplacementNamed(context, Routes.welcome);
        return;
      }
      // WE NEED TO HAVE RETURNED BY HERE
    }
    // todo is this necessary to run?
    if (!mounted) return;
    if (context.read<AppState>().isPreview) {
      //print("isPreview true");
      previewSubjectIdKey();
    }

    final selectedStudyObjectId = await getActiveSubjectId();
    print('Selected study: $selectedStudyObjectId');
    if (!mounted) return;
    if (selectedStudyObjectId == null) {
      if (isUserLoggedIn()) {
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
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
    }
    if (!mounted) return;

    if (subject != null) {
      model.activeSubject = subject;
      if (!kIsWeb) {
        // Notifications not supported on web
        scheduleStudyNotifications(context);
      }
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
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

  @override
  void onAuthenticated(Session session) {}

  @override
  void onErrorAuthenticating(String message) {}

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onUnauthenticated() {}
}
