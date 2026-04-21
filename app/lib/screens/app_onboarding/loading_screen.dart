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

class LoadingScreen extends StatefulWidget {
  final String? sessionString;
  final Map<String, String>? queryParameters;

  const LoadingScreen({super.key, this.sessionString, this.queryParameters});

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final IFrameHelper _iFrameHelper = IFrameHelper();

  @override
  void initState() {
    super.initState();
    initStudy();
  }

  Future<void> initStudy() async {
    final state = context.read<AppState>();
    try {
      await _initPreview(state);
    } catch (error, stackTrace) {
      StudyULogger.error(
        'Preview failed to initialize.',
        error: error,
        stackTrace: stackTrace,
      );
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message:
            'The preview could not be opened for this study yet. Please try resetting the preview.',
      );
      rethrow;
    }

    final selectedSubjectId = await getActiveSubjectId();
    if (!mounted) return;

    if (selectedSubjectId == null) {
      await noSubjectFound(state);
      return;
    }
    StudyULogger.info("Retrieving subject with ID: $selectedSubjectId");
    StudySubject? subject = await _retrieveSubject(selectedSubjectId);
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

  Future<void> noSubjectFound(AppState state) async {
    await cancelNotifications(context);

    final bool onBoarded = await SecureStorage.readBool('onboarded') ?? false;
    // Designer previews should skip the generic app introduction and go straight
    // to the participant study flow.
    final route = state.isPreview || onBoarded
        ? Routes.terms
        : Routes.onboarding;

    if (!mounted) return;
    _iFrameHelper.postPreviewStatus(status: 'loaded');
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
        StudyULogger.warning(
          "Could not login and retrieve the study subject: $exception",
        );
        StudyULogger.fatal('Could not login and retrieve the study subject.');
        // Try to reload the subject from cache
        try {
          subject = await Cache.loadSubject();
          StudyULogger.info("Loaded subject from cache: $subject");
        } catch (e) {
          StudyULogger.warning("No subject found in cache");
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
    final lang = AppLanguage(AppLocalizations.supportedLocales);
    final preview = study_preview.Preview(widget.queryParameters, lang);
    state.isPreview = true;
    _iFrameHelper.postPreviewStatus(status: 'loading');
    await preview.init();

    // Authorize
    final isAuthorized = await preview.handleAuthorization();
    if (!isAuthorized) {
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message:
            'The preview could not be opened right now. Please try resetting the preview.',
      );
      return;
    }
    state.selectedStudy = preview.study;

    await preview.runCommands();

    _iFrameHelper.listen(state);

    if (preview.hasRoute()) {
      // print('[PreviewApp]: Found preview route:: ${preview.selectedRoute}');

      // ELIGIBILITY CHECK
      if (preview.selectedRoute == '/eligibilityCheck') {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        // if we remove the await, we can push multiple times. warning: do not run in while(true)
        await Navigator.push<EligibilityResult>(
          context,
          EligibilityScreen.routeFor(study: preview.study),
        );
        // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
        _iFrameHelper.postRouteFinished();
        return;
      }

      // INTERVENTION SELECTION
      if (preview.selectedRoute == Routes.interventionSelection) {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.pushNamed(context, Routes.interventionSelection);
        _iFrameHelper.postRouteFinished();
        return;
      }

      state.activeSubject = await preview.getStudySubject(
        state,
        createSubject: true,
      );

      // CONSENT
      if (preview.selectedRoute == Routes.consent) {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.pushNamed<bool>(context, Routes.consent);
        _iFrameHelper.postRouteFinished();
        return;
      }

      // JOURNEY
      if (preview.selectedRoute == Routes.journey) {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.pushNamed(context, Routes.journey);
        _iFrameHelper.postRouteFinished();
        return;
      }

      // DASHBOARD
      if (preview.selectedRoute == Routes.dashboard) {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.pushReplacementNamed(context, Routes.dashboard);
        _iFrameHelper.postRouteFinished();
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
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.pushReplacementNamed(context, Routes.dashboard);
        _iFrameHelper.postRouteFinished();
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
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await Navigator.push<bool>(
          context,
          TaskScreen.routeFor(
            taskInstance: TaskInstance(
              tasks.first,
              tasks.first.schedule.completionPeriods.first.id,
            ),
          ),
        );
        _iFrameHelper.postRouteFinished();
        return;
      }
    } else {
      if (isUserLoggedIn()) {
        final subject = await preview.getStudySubject(state);
        if (subject != null) {
          state.activeSubject = subject;
          if (!mounted) return;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          Navigator.pushReplacementNamed(context, Routes.dashboard);
          return;
        } else {
          if (!mounted) return;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          Navigator.pushReplacementNamed(context, Routes.studyOverview);
          return;
        }
      } else {
        if (!mounted) return;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
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
