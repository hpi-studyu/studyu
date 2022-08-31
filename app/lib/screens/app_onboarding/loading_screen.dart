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
    final state = context.read<AppState>();
    final preview = Preview(widget.queryParameters ?? {});

    print("[PreviewApp]: InitStudy called: " + widget.queryParameters.toString());

    if (preview.containsQueryPair('mode', 'preview')) {
      final iFrameHelper = IFrameHelper();
      state.isPreview = true;
      await preview.init();

      // Authorize
      if (!await preview.handleAuthorization()) {
        print("[PreviewApp]: Preview authorization error");
        return;
      }
      state.selectedStudy = preview.study;

      await preview.runCommands();

      iFrameHelper.listen(state);

      if (preview.hasRoute()) {
        print("[PreviewApp]: Found preview route:: " + preview.selectedRoute);

        // ELIGIBILITY CHECK
        if (preview.selectedRoute == '/eligibilityCheck') {
          if (!mounted) return;
          // if we remove the await, we can push multiple times. warning: do not run in while(true)
          final result = await Navigator.push<EligibilityResult>(context, EligibilityScreen.routeFor(study: preview.study));
          // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
          iFrameHelper.postRouteFinished();
          return;
        }

        // INTERVENTION SELECTION
        if (preview.selectedRoute == Routes.interventionSelection) {
          if (!mounted) return;
          final interventionSelected = await Navigator.pushNamed(context, Routes.interventionSelection);
          iFrameHelper.postRouteFinished();
          return;
        }

        state.activeSubject = await preview.getActiveSubject(state, preview.extra);

        // CONSENT
        if (preview.selectedRoute == Routes.consent) {
          if (!mounted) return;
          final consentGiven = await Navigator.pushNamed<bool>(context, Routes.consent);
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
          print("[PreviewApp]: Route preview");
          if (!mounted) return;
          print("[PreviewApp]: Go to dashboard");
          await Navigator.pushReplacementNamed(context, Routes.dashboard);
          iFrameHelper.postRouteFinished();
          return;
        }

        // OBSERVATION [i]
        if (preview.selectedRoute == '/observation') {
          print(state.selectedStudy.observations.first.id);
          final tasks = <Task>[
            ...state.selectedStudy.observations.where((observation) => observation.id == preview.extra).toList(),
          ];
          if (!mounted) return;
          final result = await Navigator.push<TaskScreen>(context, TaskScreen.routeFor(task: tasks.first));
          iFrameHelper.postRouteFinished();
          return;
        }

      } else {
        print("[PreviewApp]: Found no preview route");
        if (!mounted) return;
        if (isUserLoggedIn()) {
          print("[PreviewApp]: Go to overview");
          Navigator.pushReplacementNamed(context, Routes.studyOverview);
          return;
        }
        print("[PreviewApp]: Go to welcome1");
        Navigator.pushReplacementNamed(context, Routes.welcome);
        return;
      }
    }
    print("[PreviewApp]: No preview");
    if (!mounted) return;
    if (context.read<AppState>().isPreview) {
      previewSubjectIdKey();
    }

    final selectedStudyObjectId = await getActiveSubjectId();
    print('[PreviewApp]: Selected study: $selectedStudyObjectId');
    if (!mounted) return;
    if (selectedStudyObjectId == null) {
      if (isUserLoggedIn()) {
        print("[PreviewApp]: Go to study selection");
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
      print("[PreviewApp]: Go to welcome2");
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
      state.activeSubject = subject;
      if (!kIsWeb) {
        // Notifications not supported on web
        scheduleStudyNotifications(context);
      }
      print("[PreviewApp]: push to dashboard");
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      print("[PreviewApp]: push to welcome3");
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
