import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stack_deferred_link/stack_deferred_link.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart'
    as study_preview;
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/services/deep_link_error_helper.dart';
import 'package:studyu_app/services/deep_link_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("LoadingScreen initState: sessionString=${widget.sessionString}, queryParameters=${widget.queryParameters}, deepLinkStudyId=${widget.deepLinkStudyId}, deepLinkInviteCode=${widget.deepLinkInviteCode}");
      if (kIsWeb && widget.deepLinkInviteCode != null) {
        return;
      }
      if (widget.hasDeepLink) {
        await _initDeepLink();
      } else if (!kIsWeb) {
        final deferredCode = await _checkForDeferredLink();
        if (!mounted) return;
        if (deferredCode != null) {
          _handleDeferredInvite(deferredCode);
        } else {
          initStudy();
        }
      } else {
        initStudy();
      }
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

  Future<String?> _checkForDeferredLink() async {
    try {
      final hasProcessed =
          await SecureStorage.readBool('has_processed_deferred_link') ?? false;
      if (hasProcessed) return null;

      String? deferredCode;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await StackDeferredLink.getInstallReferrerAndroid();
        deferredCode = info.getParam('invite_code');
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final host = Uri.parse(appDeepLinkScheme!).host;
        final result = await StackDeferredLink.getInstallReferrerIos(
          deepLinks: ['$host/invite'],
        );
        if (result != null) {
          final uri = Uri.tryParse(result.fullReferralDeepLinkPath);
          if (uri != null && uri.pathSegments.contains('invite')) {
            final idx = uri.pathSegments.indexOf('invite');
            if (idx + 1 < uri.pathSegments.length) {
              deferredCode = uri.pathSegments[idx + 1];
            }
          }
        }
      }

      if (deferredCode != null && deferredCode.isNotEmpty) {
        await SecureStorage.write('has_processed_deferred_link', 'true');
        return deferredCode;
      }
    } catch (e) {
      debugPrint("Deferred link check failed: $e");
    }
    return null;
  }

  Future<void> _handleDeferredInvite(String inviteCode) async {
    final state = context.read<AppState>();
    final result = await DeepLinkService.processDeepLink(
      studyId: null,
      inviteCode: inviteCode,
      isAuthenticated: isUserLoggedIn(),
      activeStudyId: state.activeSubject?.studyId,
    );
    if (!mounted) return;
    _handleDeepLinkResult(result, inviteCode: inviteCode);
  }

  Future<void> _initDeepLink() async {
    final state = context.read<AppState>();

    final result = await DeepLinkService.processDeepLink(
      studyId: widget.deepLinkStudyId,
      inviteCode: widget.deepLinkInviteCode,
      isAuthenticated: isUserLoggedIn(),
      activeStudyId: state.activeSubject?.studyId,
    );

    if (!mounted) {
      return;
    }

    _handleDeepLinkResult(
      result,
      studyId: widget.deepLinkStudyId,
      inviteCode: widget.deepLinkInviteCode,
    );
  }

  void _handleDeepLinkResult(
    DeepLinkResult result, {
    String? studyId,
    String? inviteCode,
  }) {
    final state = context.read<AppState>();
    switch (result) {
      case DeepLinkNeedsAuth():
        if (studyId != null) {
          state.pendingDeepLinkStudyId = studyId;
        } else if (inviteCode != null) {
          state.pendingDeepLinkInviteCode = inviteCode;
        }
        context.go('/${RouteNames.welcome}');
      case DeepLinkError(type: final errorType):
        setState(() => _error = _getErrorMessage(errorType));
      case DeepLinkSuccess(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
        :final alreadyEnrolled,
      ):
        if (alreadyEnrolled) {
          context.go('/${RouteNames.dashboard}');
        } else {
          state.selectedStudy = study;
          if (inviteCode != null) {
            state.inviteCode = inviteCode;
            state.preselectedInterventionIds = preselectedInterventionIds;
          }
          context.go('/${RouteNames.studyOverview}');
        }
    }
  }

  String _getErrorMessage(DeepLinkErrorType errorType) {
    return getDeepLinkErrorMessage(AppLocalizations.of(context)!, errorType);
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
    StudyULogger.info("No subject found, redirecting to welcome screen");
    await cancelNotifications(context);

    final bool onBoarded = await SecureStorage.readBool('onboarded') ?? false;
    // If no subject found and user has not done any onboarding, redirect to onboarding
    final route = onBoarded ? RouteNames.terms : RouteNames.onboarding;

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

  Widget _buildWebLayout() {
    final isMobile =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    if (!isMobile) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.open_link_on_mobile,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.you_have_been_invited,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _launchAppStore,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.download_app_join,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchAppStore() async {
    final inviteCode = widget.deepLinkInviteCode!;
    final link = "$appDeepLinkScheme/invite/$inviteCode";
    await Clipboard.setData(ClipboardData(text: link));

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (androidPackageName != null) {
        final referrer = Uri.encodeComponent("invite_code=$inviteCode");
        final url = Uri.parse(
          "https://play.google.com/store/apps/details?id=$androidPackageName&referrer=$referrer",
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (iosAppStoreId != null) {
        final url = Uri.parse("https://apps.apple.com/app/id$iosAppStoreId");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && widget.deepLinkInviteCode != null) {
      return _buildWebLayout();
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
                  onPressed: () => context.go('/${RouteNames.welcome}'),
                  child: Text(AppLocalizations.of(context)!.go_back),
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
