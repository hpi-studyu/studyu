import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/schedule_notifications.dart';

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
    initStudy();
    print("loading.dependencies");
  }

  Future<void> initStudy() async {
    final state = context.read<AppState>();

    /*if (widget.queryParameters.containsKey('mode') && widget.queryParameters['mode'] == 'preview') {
      var lang = context.watch<AppLanguage>();
      final preview = Preview(
        widget.queryParameters,
        lang,
      );
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
          // Either one of here or in preview.createFakeSubject
          // maybe remove
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
          await Navigator.push<bool>(
              context,
              TaskScreen.routeFor(
                  taskInstance: TaskInstance(tasks.first, tasks.first.schedule.completionPeriods.first.id)));
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
    if (!mounted) return;
    if (context.read<AppState>().isPreview) {
      previewSubjectIdKey();
    }*/

    final selectedStudyObjectId = await getActiveSubjectId();
    print('Subject ID: $selectedStudyObjectId');
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
      print("Try signing in again $e");
      try {
        // Try signing in again. Needed if JWT is expired
        final signInRes = await signInParticipant();

        if (!signInRes) {
          await askUserForV2Migration(selectedStudyObjectId);
          return;
        }

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
      state.activeSubject = subject;
      scheduleNotifications(context);
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
                '${AppLocalizations.of(context).loading}...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> askUserForV2Migration(String selectedStudyObjectId) async {
    // todo translate
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        // initStudy();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Migrate my account"),
      onPressed: () async {
        final migrateRes = await migrateParticipantToV2(selectedStudyObjectId);
        if (migrateRes) {
          print("Successfully migrated to V2");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully migrated to V2')));
        } else {
          print("Error when trying to migrate to V2");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error when trying to migrate to V2')));
        }
        initStudy();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("StudyU Version 2"),
      content: const Text("It seems like your account needs to be migrated to our new StudyU V2 platform."
          "Would you like to continue and migrate your account? You will not be able to continue your study, until you migrate your account."
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: false,
    );
  }

  Future<bool> migrateParticipantToV2(String selectedStudyObjectId) async {
    // todo move to user.dart
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(userEmailKey) && prefs.containsKey(userPasswordKey)) {
      try {
        // create new account
        if (await anonymousSignUp()) {
          // call supabase function to update user_id to new user id
          // by matching a study_subject entry with the current subject ID
          try {
            await Supabase.instance.client.rpc(
              'migrate_to_v2',
              params: {
                'participant_user_id': Supabase.instance.client.auth.currentUser?.id,
                'participant_subject_id': selectedStudyObjectId,
              },
            ).single();
          } on PostgrestException catch (error) {
            print('Supabase migrate_to_v2 Error: ${error.message}');
          }
          return true;
        } else {
          return false;
        }
      } catch (error, stacktrace) {
        SupabaseQuery.catchSupabaseException(error, stacktrace);
      }
    }
    return false;
  }
}
