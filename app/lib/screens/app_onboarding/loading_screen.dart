import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/notifications.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionString;
  final Map<String, String> queryParameters;

  const LoadingScreen({Key key, this.sessionString, this.queryParameters})
      : super(key: key);

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
    final selectedStudyObjectId = await getActiveSubjectId();
    if (!mounted) return;
    if (selectedStudyObjectId == null) {
      if (widget.queryParameters != null &&
          widget.queryParameters['mode'] != null &&
          widget.queryParameters['mode'] == 'preview') {
        if (widget.queryParameters['studyid'] == null ||
            widget.queryParameters['studyid'].isEmpty ||
            widget.queryParameters['session'] == null ||
            widget.queryParameters['session'].isEmpty ||
            widget.queryParameters['studyid'] == null ||
            widget.queryParameters['studyid'].isEmpty) {
          print('Parameter Error');
          return;
        }
        // maybe use another test account for study preview that will be deleted after study goes live
        //final success = await anonymousSignUp();
        final String session =
            Uri.decodeComponent(widget.queryParameters['session']);
        final recovery =
            await Supabase.instance.client.auth.recoverSession(session);
        if (recovery.error != null) {
          print('Recovery Error: ${recovery.error.toString()}');
          return;
        } // handle error on UI level
        final study = await SupabaseQuery.getById<Study>(
            widget.queryParameters['studyid'],);
        // todo allow preview for published studies? Are results visible?
        if (study == null) {
          print('Study Error: ${recovery.error.toString()}');
          return;
        } // handle error on UI level
        if (!mounted) return;
        context.read<AppState>().selectedStudy = study;
        Navigator.pushReplacementNamed(context, Routes.studyOverview);
        return;
      } else if (isUserLoggedIn()) {
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      } else {
        Navigator.pushReplacementNamed(context, Routes.welcome);
        return;
      }
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
                '${AppLocalizations.of(context).loading}...',
                style: Theme.of(context).textTheme.headline4,
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
