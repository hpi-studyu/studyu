import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/main.dart' show navigatorKey;
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
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
import 'package:supabase/supabase.dart'
    show AuthApiException, PostgrestException;

class SubjectDeletedException implements Exception {
  const SubjectDeletedException();

  @override
  String toString() =>
      'SubjectDeletedException: subject no longer exists in the backend';
}

@visibleForTesting
String initialRouteForMissingSubjectRoute({
  required bool isPreview,
  required bool onBoarded,
}) {
  if (isPreview) return '/${RouteNames.terms}';
  return onBoarded ? '/${RouteNames.welcome}' : '/${RouteNames.onboarding}';
}

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
  final IFrameHelper _iFrameHelper = IFrameHelper();
  bool _previewNavigationInProgress = false;
  String? _pendingPreviewRoute;
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

    // 1. Check login status
    final loggedIn = isUserLoggedIn();

    // 2. Only try to get an active study ID if they are actually logged in
    final activeStudyId = loggedIn ? await _getCurrentStudyId(state) : null;

    // 3. ALWAYS process/validate the deep link first
    final result = await DeepLinkService.processDeepLink(
      studyId: studyId,
      inviteCode: inviteCode,
      isAuthenticated: loggedIn,
      activeStudyId: activeStudyId,
    );

    if (!mounted) return;

    // 4. Handle the result (Errors will be caught here, NeedsAuth will route to onboarding)
    await _handleDeepLinkResult(result);
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

    if (kIsWeb && widget.hasDeepLink) {
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

  Future<void> _handleDeepLinkResult(DeepLinkResult result) async {
    final state = context.read<AppState>();
    switch (result) {
      case DeepLinkNeedsAuth(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
      ):
        _storePendingDeepLink(
          studyId: inviteCode != null ? null : study.id,
          inviteCode: inviteCode,
        );
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

        final confirmed = await _confirmSwitchToDeepLinkedStudy(study);
        if (!confirmed) {
          if (!mounted) return;
          context.go('/${RouteNames.dashboard}');
          return;
        }

        if (alreadyEnrolled) {
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
    final activeSubjectId = await getActiveSubjectId();
    if (activeSubjectId == null) {
      return null;
    }

    final activeSubject = state.activeSubject;
    if (activeSubject != null && activeSubject.id == activeSubjectId) {
      return activeSubject.studyId;
    }

    try {
      final cachedSubject = await Cache.loadSubject();
      if (cachedSubject.id == activeSubjectId) {
        return cachedSubject.studyId;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<StudySubject?> _getCurrentSubject(AppState state) async {
    final activeSubjectId = await getActiveSubjectId();
    if (activeSubjectId == null) {
      return null;
    }

    final activeSubject = state.activeSubject;
    if (activeSubject != null && activeSubject.id == activeSubjectId) {
      return activeSubject;
    }

    try {
      final cachedSubject = await Cache.loadSubject();
      if (cachedSubject.id == activeSubjectId) {
        return cachedSubject;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _confirmSwitchToDeepLinkedStudy(Study targetStudy) async {
    final state = context.read<AppState>();
    final currentSubject = await _getCurrentSubject(state);
    if (currentSubject == null) {
      return true;
    }

    if (!mounted) return false;

    if (currentSubject.studyId == targetStudy.id) {
      return await StudySwitchDialogs.confirmDeepLinkWarning(
        context,
        targetStudy,
        currentSubject,
      );
    }

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
    final l10n = AppLocalizations.of(context)!;
    try {
      final previewHandledNavigation = await _initPreview(state, l10n);
      if (previewHandledNavigation) return;
    } catch (error, stackTrace) {
      StudyULogger.error(
        l10n.preview_failed_to_initialize,
        error: error,
        stackTrace: stackTrace,
      );
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message: l10n.preview_overlay_study_not_ready,
      );
      // Do not rethrow: the call site is unawaited; an unhandled async
      // exception would crash the app rather than showing a graceful error.
      return;
    }

    final selectedSubjectId = await getActiveSubjectId();
    if (!mounted) return;

    if (selectedSubjectId == null) {
      await noSubjectFound(state);
      return;
    }
    StudyULogger.info("Retrieving subject with ID: $selectedSubjectId");
    StudySubject? subject;
    try {
      subject = await _retrieveSubject(selectedSubjectId);
    } on SubjectDeletedException {
      StudyULogger.warning(
        "Subject $selectedSubjectId was deleted from backend. Showing recovery screen.",
      );
      if (!mounted) return;
      context.go(
        '/${RouteNames.appErrorScreen}',
        extra: AppErrorScreenArguments(
          selectedSubjectId: selectedSubjectId,
          reason: AppErrorReason.deletedStudy,
        ),
      );
      return;
    }
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

  Future<void> noSubjectFound(AppState state) async {
    StudyULogger.info("No subject found");
    await cancelNotifications(context);

    await _restoreParticipantSession();
    if (isUserLoggedIn() && !state.isPreview) {
      if (!mounted) return;
      context.goNamed(RouteNames.welcome);
      return;
    }

    final route = initialRouteForMissingSubjectRoute(
      isPreview: state.isPreview,
      onBoarded: await SecureStorage.readBool('onboarded') ?? false,
    );

    if (!mounted) return;
    _iFrameHelper.postPreviewStatus(status: 'loaded');
    context.go(route);
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

  Future<bool> _initPreview(AppState state, AppLocalizations l10n) async {
    if (state.isPreview) previewSubjectIdKey();
    if (widget.queryParameters == null || widget.queryParameters!.isEmpty) {
      return false;
    }

    StudyULogger.info(
      "Preview: Found query parameters ${widget.queryParameters}",
    );
    final lang = AppLanguage(AppLocalizations.supportedLocales);
    final preview = study_preview.Preview(widget.queryParameters, lang);
    state.isPreview = true;
    _iFrameHelper.postPreviewStatus(status: 'loading');
    await preview.init();

    final isAuthorized = await preview.handleAuthorization();
    if (!isAuthorized) {
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message: l10n.preview_overlay_reset_hint,
      );
      return true;
    }
    state.selectedStudy = preview.study;

    await preview.runCommands();

    _iFrameHelper.listen(
      state,
      onNavigate: (route) => _navigatePreviewRoute(state, route, l10n),
    );

    if (preview.hasRoute()) {
      // print('[PreviewApp]: Found preview route:: ${preview.selectedRoute}');

      if (preview.selectedRoute == '/${RouteNames.studyOverview}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.studyOverview}');
        return true;
      }

      // ELIGIBILITY CHECK
      if (preview.selectedRoute == '/${RouteNames.eligibilityCheck}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        // if we remove the await, we can push multiple times. warning: do not run in while(true)
        await context.push<EligibilityResult>(
          '/${RouteNames.eligibilityCheck}',
          extra: preview.study,
        );
        // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // INTERVENTION SELECTION
      if (preview.selectedRoute == '/${RouteNames.interventionSelection}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push('/${RouteNames.interventionSelection}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      state.activeSubject = await preview.getStudySubject(
        state,
        createSubject: true,
      );

      // CONSENT
      if (preview.selectedRoute == '/${RouteNames.consent}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push<bool>('/${RouteNames.consent}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // JOURNEY
      if (preview.selectedRoute == '/${RouteNames.journey}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push('/${RouteNames.journey}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // DASHBOARD
      if (preview.selectedRoute == '/${RouteNames.dashboard}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.dashboard}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // INTERVENTION [i]
      if (preview.selectedRoute == '/intervention') {
        // todo not sure which includeBaseline statement is needed.
        // Either one of here or in preview.createFakeSubject
        // maybe remove
        state.selectedStudy!.schedule.includeBaseline = false;
        state.activeSubject!.study.schedule.includeBaseline = false;
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.dashboard}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // OBSERVATION [i]
      if (preview.selectedRoute == '/observation') {
        final tasks = <Task>[
          ...state.selectedStudy!.observations.where(
            (observation) => observation.id == preview.extra,
          ),
        ];
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push<bool>(
          '/${RouteNames.task}',
          extra: TaskInstance(
            tasks.first,
            tasks.first.schedule.completionPeriods.first.id,
          ),
        );
        _iFrameHelper.postRouteFinished();
        return true;
      }
    } else {
      if (isUserLoggedIn()) {
        final subject = await preview.getStudySubject(state);
        if (subject != null) {
          state.activeSubject = subject;
          if (!mounted) return true;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          context.go('/${RouteNames.dashboard}');
          return true;
        } else {
          if (!mounted) return true;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          context.go('/${RouteNames.studyOverview}');
          return true;
        }
      } else {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.welcome}');
        return true;
      }
    }
    return true;
  }

  Future<void> _navigatePreviewRoute(
    AppState state,
    String? route,
    AppLocalizations l10n,
  ) async {
    if (_previewNavigationInProgress) {
      _pendingPreviewRoute = route;
      return;
    }
    _previewNavigationInProgress = true;
    bool navigationPerformed = false;

    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      Future<bool> ensureSubject() async {
        if (state.activeSubject != null) return true;
        if (state.selectedStudy == null) return false;

        final preview = study_preview.Preview({
          ...?widget.queryParameters,
          if (route != null) 'route': route,
        }, AppLanguage(AppLocalizations.supportedLocales));
        await preview.init();
        // Recover the Supabase session before making authenticated calls.
        if (!await preview.handleAuthorization()) return false;
        // Prefer the already-fetched study from state over the one from
        // handleAuthorization so the designer's latest edits are used.
        if (state.selectedStudy != null) preview.study = state.selectedStudy;
        state.activeSubject = await preview.getStudySubject(
          state,
          createSubject: true,
        );
        return state.activeSubject != null;
      }

      Future<void> waitForNavigator() async {
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      Future<void> replaceNamed(String routeName) async {
        await waitForNavigator();
        navigatorKey.currentContext?.go(routeName);
      }

      Future<void> replaceWithEligibility() async {
        if (state.selectedStudy == null) return;
        await waitForNavigator();
        navigatorKey.currentState?.pushReplacement(
          EligibilityScreen.routeFor(study: state.selectedStudy),
        );
      }

      if (route == null ||
          route.isEmpty ||
          route == 'studyOverview' ||
          route == '/${RouteNames.studyOverview}') {
        await replaceNamed('/${RouteNames.studyOverview}');
        navigationPerformed = true;
        return;
      }

      if (route == 'eligibilityCheck') {
        if (state.selectedStudy == null) return;
        await replaceWithEligibility();
        navigationPerformed = true;
        return;
      }

      if (route == '/${RouteNames.interventionSelection}' ||
          route == 'interventionSelection') {
        await replaceNamed('/${RouteNames.interventionSelection}');
        navigationPerformed = true;
        return;
      }

      if (!await ensureSubject()) {
        _iFrameHelper.postPreviewStatus(
          status: 'error',
          message: l10n.preview_overlay_route_open_failed,
        );
        return;
      }

      if (route == 'consent') {
        await replaceNamed('/${RouteNames.consent}');
        navigationPerformed = true;
      } else if (route == 'journey') {
        await replaceNamed('/${RouteNames.journey}');
        navigationPerformed = true;
      } else if (route == 'dashboard') {
        await replaceNamed('/${RouteNames.dashboard}');
        navigationPerformed = true;
      }
    } finally {
      _previewNavigationInProgress = false;
      final pendingRoute = _pendingPreviewRoute;
      _pendingPreviewRoute = null;
      if (pendingRoute != null && pendingRoute != route) {
        await _navigatePreviewRoute(state, pendingRoute, l10n);
      } else if (navigationPerformed) {
        _iFrameHelper.postPreviewStatus(status: 'loaded');
      }
    }
  }

  @override
  void dispose() {
    IFrameHelper.cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && widget.hasDeepLink) {
      return DeepLinkWebLandingPage(
        inviteCode: widget.deepLinkInviteCode,
        studyId: widget.deepLinkStudyId,
      );
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
                  AppLocalizations.of(context)!.error,
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
              Text('${AppLocalizations.of(context)!.loading}...'),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
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
