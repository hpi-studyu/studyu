import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart'
    as study_preview;
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart' show AuthApiException, PostgrestException;

class SubjectDeletedException implements Exception {
  const SubjectDeletedException();

  @override
  String toString() => 'SubjectDeletedException: subject no longer exists in the backend';
}

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
    if (!mounted) return;

    if (selectedSubjectId == null) {
      await noSubjectFound();
      return;
    }
    StudyULogger.info("Retrieving subject with ID: $selectedSubjectId");
    StudySubject? subject;
    try {
      subject = await _retrieveSubject(selectedSubjectId);
    } on SubjectDeletedException {
      StudyULogger.warning(
        "Subject $selectedSubjectId was deleted from backend. Clearing local data.",
      );
      await deleteLocalData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }
    if (!mounted) return;
    if (subject != null) {
      subject = await Cache.synchronize(subject);
      if (!mounted) return;
      state.activeSubject = subject;
      state.init(context);
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      StudyULogger.warning("No subject found for ID: $selectedSubjectId.");
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        Routes.appErrorScreen,
        arguments: selectedSubjectId,
      );
    }
  }

  Future<void> noSubjectFound() async {
    await cancelNotifications(context);

    final bool onBoarded = await SecureStorage.readBool('onboarded') ?? false;
    // If no subject found and user has not done any onboarding, redirect to onboarding
    final route = onBoarded ? Routes.terms : Routes.onboarding;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<StudySubject?> _fetchRemoteSubject(String selectedStudyObjectId) {
    return SupabaseQuery.getById<StudySubject>(
      selectedStudyObjectId,
      selectedColumns: [
        '*',
        // Retrieve the related study along with its fitbit credentials
        'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
        'subject_progress(*)',
      ],
    );
  }

  Future<StudySubject?> _retrieveSubject(String selectedStudyObjectId) async {
    try {
      return await _fetchRemoteSubject(selectedStudyObjectId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Row does not exist — subject was deleted from the database.
        // Do not retry or fall back to cache, as that would show stale data.
        StudyULogger.warning("Subject not found in DB (deleted): $e");
        throw const SubjectDeletedException();
      }
      StudyULogger.warning(
        "Could not retrieve subject, maybe JWT is expired, try logging in: $e",
      );
    } catch (exception) {
      StudyULogger.warning(
        "Could not retrieve subject, maybe JWT is expired, try logging in: $exception",
      );
    }

    // JWT/network error path — retry with login
    try {
      if (await signInParticipant()) {
        return await _fetchRemoteSubject(selectedStudyObjectId);
      }
    } on AuthApiException catch (e) {
      // Credentials were rejected — the auth account no longer exists.
      StudyULogger.warning("Invalid credentials during re-login: $e");
      throw const SubjectDeletedException();
    } catch (exception) {
      StudyULogger.warning(
        "Could not login and retrieve the study subject: $exception",
      );
      StudyULogger.fatal('Could not login and retrieve the study subject.');
      // Only fall back to cache for network errors (device offline)
      try {
        final cached = await Cache.loadSubject();
        StudyULogger.info("Loaded subject from cache: $cached");
        return cached;
      } catch (e) {
        StudyULogger.warning("No subject found in cache");
      }
    }
    return null;
  }

  Future<void> _initPreview(AppState state) async {
    if (state.isPreview) previewSubjectIdKey();
    if (widget.queryParameters == null || widget.queryParameters!.isEmpty) {
      return;
    }

    StudyULogger.info(
      "Preview: Found query parameters ${widget.queryParameters}",
    );
    final lang = AppLanguage(AppLocalizations.supportedLocales);
    final preview = study_preview.Preview(widget.queryParameters, lang);
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

      state.activeSubject = await preview.getStudySubject(
        state,
        createSubject: true,
      );

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
        final tasks = <Task>[
          ...state.selectedStudy!.observations.where(
            (observation) => observation.id == preview.extra,
          ),
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
