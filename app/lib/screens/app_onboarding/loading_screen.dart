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

    if (widget.queryParameters != null && widget.queryParameters['mode'] != null &&
        widget.queryParameters['mode'] == 'preview') {
      if (!mounted) return;
      context.read<AppState>().isPreview = true;
    }

    initStudy();
    print("returned from initStudy");
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>();
    final selectedStudyObjectId = await getActiveSubjectId();
    print("initStudy");
    if (!mounted) return;
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
      print("preview");
      // maybe use another test account for study preview that will be deleted after study goes live
      //final success = await anonymousSignUp();
      final String session =
      Uri.decodeComponent(widget.queryParameters['session']);
      final recovery =
      await Supabase.instance.client.auth.recoverSession(session);
      // handle error on UI level
      if (recovery.error != null) {
        print('Recovery Error: ${recovery.error.toString()}');
        return;
      }

      final Study study = await SupabaseQuery.getById<Study>( // todo getById<StudySubject> if subscribed
        widget.queryParameters['studyid'],);
      print('study: ${study.id}');
      // todo allow preview for published studies? Are results visible?
      // handle error on UI level
      if (study == null) {
        print('Study Error: ${recovery.error.toString()}');
        return;
      }

      if (!mounted) return;
      model.selectedStudy = study;
      StudySubject subject;

      if (selectedStudyObjectId != null) {
        print("Found subject id in shared prefs");
        // found study subject
        subject = await SupabaseQuery.getById<StudySubject>(
          selectedStudyObjectId,
          selectedColumns: [
            '*',
            'study!study_subject_studyId_fkey(*)',
            'subject_progress(*)',
          ],
        );
        if (subject != null) {
          // user is already subscribed to a study
          model.activeSubject = subject;
          print("equal check: " + subject.studyId + " " + study.id);
          if (subject.studyId == study.id) {
            // user is subscribed to the currently shown study
            print('go to dashboard');
            if (!mounted) return;
            context.read<AppState>().isPreview = false;
            print('dashboard');
            Navigator.pushReplacementNamed(context, Routes.dashboard);
            return;
          } else {
            // delete current study progress
            //print("delete");
            //subject.delete();
            //deleteActiveStudyReference();
            //Navigator.pushNamedAndRemoveUntil(context, Routes.studySelection, (_) => false);
          }
        }

      }
      // user still has to subscribe to the study
      print('go to studyOverview');
      if (!mounted) return;
      context.read<AppState>().isPreview = false;
      print('studyOverview');
      Navigator.pushReplacementNamed(context, Routes.studyOverview);
      return;
    } else if (!context.read<AppState>().isPreview) {
      print('no preview');
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
        print("no preview dashboard");
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else {
        print("no preview welcome");
        Navigator.pushReplacementNamed(context, Routes.welcome);
      }
    } else {
      print("Nix");
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
