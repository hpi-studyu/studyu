import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class LoadingScreen extends StatefulWidget {
  final String? sessionString;
  final Map<String, String>? queryParameters;

  const LoadingScreen({super.key, this.sessionString, this.queryParameters});

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    initStudy();
  }

  Future<void> initStudy() async {
    final state = context.read<AppState>();
    await _initPreview(state);

    final selectedSubjectId = await getActiveSubjectId();
    StudyULogger.info('Subject ID: $selectedSubjectId');
    if (!mounted) return;

    if (selectedSubjectId == null) {
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }
    StudySubject? subject = await _retrieveSubject(selectedSubjectId);
    if (!mounted) return;
    if (subject != null) {
      subject = await Cache.synchronize(subject);
      if (!mounted) return;
      state.activeSubject = subject;
      state.init(context);
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
  }

  Future<StudySubject?> _fetchRemoteSubject(String selectedStudyObjectId) {
    return SupabaseQuery.getById<StudySubject>(
      selectedStudyObjectId,
      selectedColumns: [
        '*',
        'study!study_subject_studyId_fkey(*)',
        'subject_progress(*)',
      ],
    );
  }

  Future<StudySubject?> _retrieveSubject(String selectedStudyObjectId) async {
    StudySubject? subject;
    try {
      subject = await _fetchRemoteSubject(selectedStudyObjectId);
    } catch (exception) {
      StudyULogger.warning(
        "Could not retrieve subject, maybe JWT is expired, try logging in: $exception",
      );
      try {
        // Try signing in again. Needed if JWT is expired
        if (await signInParticipant()) {
          subject = await _fetchRemoteSubject(selectedStudyObjectId);
        }
      } catch (exception) {
        if (exception is SocketException) {
          subject = await Cache.loadSubject();
          StudyULogger.info("Offline mode with cached subject: $subject");
        } else {
          // TODO further analyze this. How to recreate:
          // 1. Participate in a study and wait some time until playstore uploads
          // a backup of your current subject
          // 2. Leave the study via the menu to delete all remote data
          // 3. Uninstall the app and reinstall
          // 4. Open the app but do not join a study
          // 5. Restart the app. Either only this error shows up, worst case is
          // app hangs and is unresponsive
          StudyULogger.fatal('Could not login and retrieve the study subject. '
              'One reason for this might be that the study subject is no '
              'longer available and only resides in app backup');
          throw Exception("Remote subject not found");
        }
      }
    }
    return subject;
  }

  Future<void> _initPreview(AppState state) async {
    if (state.isPreview) previewSubjectIdKey();
    if (widget.queryParameters == null || widget.queryParameters!.isEmpty) {
      return;
    }

    StudyULogger.info(
      "Preview: Found query parameters ${widget.queryParameters}",
    );
    //final lang = context.watch<AppLanguage>();
    final lang = AppLanguage(AppLocalizations.supportedLocales);
    final preview = Preview(
      widget.queryParameters,
      lang,
    );
    final iFrameHelper = IFrameHelper();
    state.isPreview = true;
    await preview.init();

    // Authorize
    if (!await preview.handleAuthorization()) {
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
        await Navigator.push<EligibilityResult>(
          context,
          EligibilityScreen.routeFor(study: preview.study),
        );
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

      state.activeSubject =
          await preview.getStudySubject(state, createSubject: true);

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
        state.selectedStudy!.schedule.includeBaseline = false;
        state.activeSubject!.study.schedule.includeBaseline = false;
        if (!mounted) return;
        await Navigator.pushReplacementNamed(context, Routes.dashboard);
        iFrameHelper.postRouteFinished();
        return;
      }

      // OBSERVATION [i]
      if (preview.selectedRoute == '/observation') {
        print(state.selectedStudy!.observations.first.id);
        final tasks = <Task>[
          ...state.selectedStudy!.observations
              .where((observation) => observation.id == preview.extra),
        ];
        if (!mounted) return;
        await Navigator.push<bool>(
          context,
          TaskScreen.routeFor(
            taskInstance: TaskInstance(
              tasks.first,
              tasks.first.schedule.completionPeriods.first.id,
            ),
          ),
        );
        iFrameHelper.postRouteFinished();
        return;
      }
    } else {
      if (isUserLoggedIn()) {
        final subject = await preview.getStudySubject(state);
        if (subject != null) {
          state.activeSubject = subject;
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, Routes.dashboard);
          return;
        } else {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, Routes.studyOverview);
          return;
        }
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Routes.welcome);
        return;
      }
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
                '${AppLocalizations.of(context)!.loading}...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

/*if (!signInRes) {
        final migrateRes = await migrateParticipantToNewDB(selectedStudyObjectId);
        if (migrateRes) {
          print("Successfully migrated to the new database");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully migrated to the new database.')));
        } else {
          print("Error when trying to migrate to the new database");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error when migrating to the new database.')));
        }
        initStudy();
        return;
      }*/

/*Future<bool> migrateParticipantToNewDB(String selectedStudyObjectId) async {
    if (await SecureStorage.containsKey(userEmailKey) && await SecureStorage.containsKey(userPasswordKey)) {
      try {
        // create new account
        if (await anonymousSignUp()) {
          // call supabase function to update user_id to new user id
          // by matching a study_subject entry with the current subject ID
          try {
            await Supabase.instance.client.rpc(
              'migrate_db',
              params: {
                'participant_user_id': Supabase.instance.client.auth.currentUser?.id,
                'participant_subject_id': selectedStudyObjectId,
              },
            ).single();
          } on PostgrestException catch (error) {
            print('Supabase migrate_db Error: ${error.message}');
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
  }*/
}
