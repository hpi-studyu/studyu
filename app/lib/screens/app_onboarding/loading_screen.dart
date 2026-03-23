import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart'
    as study_preview;
import 'package:studyu_app/screens/app_onboarding/study_switch_dialogs.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/services/deep_link_error_helper.dart';
import 'package:studyu_app/services/deep_link_service.dart';
import 'package:studyu_app/services/deferred_link_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/widgets/deep_link_onboarding_widgets.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class LoadingScreen extends StatefulWidget {
  final String? sessionString;
  final Map<String, String>? queryParameters;
  final String? deepLinkStudyId;
  final String? deepLinkInviteCode;

  const LoadingScreen({
    super.key,
    this.sessionString,
    this.queryParameters,
    this.deepLinkStudyId,
    this.deepLinkInviteCode,
  });

  bool get hasDeepLink => deepLinkStudyId != null || deepLinkInviteCode != null;

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String? _error;

  Future<void> _restoreParticipantSession() async {
    if (isUserLoggedIn()) return;
    final hasStoredCredentials =
        await SecureStorage.containsKey(userEmailKey) &&
        await SecureStorage.containsKey(userPasswordKey);
    if (!hasStoredCredentials) return;
    await signInParticipant();
  }

  void _storePendingDeepLink({String? studyId, String? inviteCode}) {
    final state = context.read<AppState>();
    state.pendingDeepLinkStudyId = studyId;
    state.pendingDeepLinkInviteCode = inviteCode;
  }

  Future<void> _handleIncomingDeepLink({
    String? studyId,
    String? inviteCode,
  }) async {
    final state = context.read<AppState>();
    final onboarded = await SecureStorage.readBool('onboarded') ?? false;

    if (!isUserLoggedIn()) {
      _storePendingDeepLink(studyId: studyId, inviteCode: inviteCode);
      if (!mounted) return;
      context.go('/${onboarded ? RouteNames.terms : RouteNames.onboarding}');
      return;
    }

    final activeStudyId = await _getCurrentStudyId(state);
    final result = await DeepLinkService.processDeepLink(
      studyId: studyId,
      inviteCode: inviteCode,
      isAuthenticated: true,
      activeStudyId: activeStudyId,
    );
    if (!mounted) return;
    await _handleDeepLinkResult(
      result,
      studyId: studyId,
      inviteCode: inviteCode,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runStartupFlow();
    });
  }

  @override
  void didUpdateWidget(LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deepLinkInviteCode != oldWidget.deepLinkInviteCode ||
        widget.deepLinkStudyId != oldWidget.deepLinkStudyId ||
        widget.queryParameters != oldWidget.queryParameters) {
      if (widget.hasDeepLink) {
        // Reset state so loading spinner shows again instead of old error
        setState(() => _error = null);
        _initDeepLink();
      }
    }
  }

  Future<void> _runStartupFlow() async {
    await _restoreParticipantSession();

    if (kIsWeb && widget.deepLinkInviteCode != null) {
      return;
    }

    if (widget.hasDeepLink) {
      await _handleIncomingDeepLink(
        studyId: widget.deepLinkStudyId,
        inviteCode: widget.deepLinkInviteCode,
      );
      return;
    }

    if (!kIsWeb) {
      final deferredCode = await DeferredLinkService.checkForDeferredLink();
      if (!mounted) return;
      if (deferredCode != null) {
        await _handleDeferredInvite(deferredCode);
        return;
      }
    }

    await initStudy();
  }

  Future<void> _handleDeferredInvite(String inviteCode) async {
    await _handleIncomingDeepLink(inviteCode: inviteCode);
  }

  Future<void> _initDeepLink() async {
    await _handleIncomingDeepLink(
      studyId: widget.deepLinkStudyId,
      inviteCode: widget.deepLinkInviteCode,
    );
  }

  Future<void> _handleDeepLinkResult(
    DeepLinkResult result, {
    String? studyId,
    String? inviteCode,
  }) async {
    final state = context.read<AppState>();
    switch (result) {
      case DeepLinkNeedsAuth(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
      ):
        _storePendingDeepLink(studyId: study.id, inviteCode: inviteCode);
        state.preselectedInterventionIds = preselectedInterventionIds;

        final onBoarded = await SecureStorage.readBool('onboarded') ?? false;
        if (!mounted) return;
        context.go('/${onBoarded ? RouteNames.terms : RouteNames.onboarding}');

      case DeepLinkError(type: final errorType, :final errorValue):
        setState(() => _error = _getErrorMessage(errorType, errorValue));
      case DeepLinkSuccess(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
        :final alreadyEnrolled,
      ):
        state.selectedStudy = study;
        if (inviteCode != null) {
          state.inviteCode = inviteCode;
          state.preselectedInterventionIds = preselectedInterventionIds;
        }

        if (alreadyEnrolled) {
          if (!mounted) return;
          context.go('/${RouteNames.dashboard}');
          return;
        }

        final confirmed = await _confirmSwitchToDeepLinkedStudy(study);
        if (!confirmed) {
          if (!mounted) return;
          context.go('/${RouteNames.dashboard}');
          return;
        }

        if (!mounted) return;
        context.go('/${RouteNames.studyOverview}');
    }
  }

  String _getErrorMessage(DeepLinkErrorType errorType, [String? errorValue]) {
    return getDeepLinkErrorMessage(
      AppLocalizations.of(context)!,
      errorType,
      errorValue,
    );
  }

  Future<void> _acknowledgeDeepLinkError() async {
    if (context.canPop()) {
      context.pop();
      return;
    }

    if (!mounted) return;
    context.goNamed(RouteNames.loading);
  }

  Future<String?> _getCurrentStudyId(AppState state) async {
    if (state.activeSubject?.studyId != null) {
      return state.activeSubject!.studyId;
    }
    try {
      final cachedSubject = await Cache.loadSubject();
      return cachedSubject.studyId;
    } catch (_) {
      return null;
    }
  }

  Future<StudySubject?> _getCurrentSubject(AppState state) async {
    if (state.activeSubject != null) {
      return state.activeSubject;
    }
    try {
      return await Cache.loadSubject();
    } catch (_) {
      return null;
    }
  }

  Future<bool> _confirmSwitchToDeepLinkedStudy(Study targetStudy) async {
    final state = context.read<AppState>();
    final currentSubject = await _getCurrentSubject(state);
    if (currentSubject == null || currentSubject.studyId == targetStudy.id) {
      return true;
    }

    if (!mounted) return false;

    final confirmedSwitch =
        await StudySwitchDialogs.confirmSwitchToDeepLinkedStudy(
          context,
          targetStudy,
          currentSubject,
        );

    if (!confirmedSwitch) {
      return false;
    }

    state.activeSubject = null;
    state.selectedStudy = null;
    return true;
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
    StudySubject? subject = await _retrieveSubject(selectedSubjectId);
    if (!mounted) return;
    if (subject != null) {
      subject = await Cache.synchronize(subject);
      if (!mounted) return;
      state.activeSubject = subject;
      state.init(context);
      context.go('/${RouteNames.dashboard}');
    } else {
      StudyULogger.warning("No subject found for ID: $selectedSubjectId.");
      if (!mounted) return;
      context.go('/${RouteNames.appErrorScreen}', extra: selectedSubjectId);
    }
  }

  Future<void> noSubjectFound() async {
    StudyULogger.info("No subject found");
    await cancelNotifications(context);

    await _restoreParticipantSession();
    if (isUserLoggedIn()) {
      if (!mounted) return;
      context.goNamed(RouteNames.welcome);
      return;
    }

    final bool onBoarded = await SecureStorage.readBool('onboarded') ?? false;
    // If onboarding is done, return to welcome; otherwise show onboarding.
    final route = onBoarded ? RouteNames.welcome : RouteNames.onboarding;

    if (!mounted) return;
    context.goNamed(route);
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
      if (preview.selectedRoute == '/${RouteNames.eligibilityCheck}') {
        if (!mounted) return;
        // if we remove the await, we can push multiple times. warning: do not run in while(true)
        await context.push<EligibilityResult>(
          '/${RouteNames.eligibilityCheck}',
          extra: preview.study,
        );
        // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
        iFrameHelper.postRouteFinished();
        return;
      }

      // INTERVENTION SELECTION
      if (preview.selectedRoute == '/${RouteNames.interventionSelection}') {
        if (!mounted) return;
        await context.push('/${RouteNames.interventionSelection}');
        iFrameHelper.postRouteFinished();
        return;
      }

      state.activeSubject = await preview.getStudySubject(
        state,
        createSubject: true,
      );

      // CONSENT
      if (preview.selectedRoute == '/${RouteNames.consent}') {
        if (!mounted) return;
        await context.push<bool>('/${RouteNames.consent}');
        iFrameHelper.postRouteFinished();
        return;
      }

      // JOURNEY
      if (preview.selectedRoute == '/${RouteNames.journey}') {
        if (!mounted) return;
        await context.push('/${RouteNames.journey}');
        iFrameHelper.postRouteFinished();
        return;
      }

      // DASHBOARD
      if (preview.selectedRoute == '/${RouteNames.dashboard}') {
        if (!mounted) return;
        context.go('/${RouteNames.dashboard}');
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
        context.go('/${RouteNames.dashboard}');
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
        await context.push<bool>(
          '/${RouteNames.task}',
          extra: TaskInstance(
            tasks.first,
            tasks.first.schedule.completionPeriods.first.id,
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
          context.go('/${RouteNames.dashboard}');
          return;
        } else {
          if (!mounted) return;
          context.go('/${RouteNames.studyOverview}');
          return;
        }
      } else {
        if (!mounted) return;
        context.go('/${RouteNames.welcome}');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && widget.deepLinkInviteCode != null) {
      return DeepLinkWebLandingPage(inviteCode: widget.deepLinkInviteCode!);
    }
    if (_error != null) {
      FlutterNativeSplash.remove(); // Force remove splash to ensure visibility
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.deep_link_error_title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _acknowledgeDeepLinkError,
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
