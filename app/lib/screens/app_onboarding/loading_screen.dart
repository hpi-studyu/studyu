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
    print('returned from initStudy');
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>();
    String selectedStudyObjectId = await getActiveSubjectId();
    print('initStudy');
    if (!mounted) return;

    if (widget.queryParameters != null && widget.queryParameters['mode'] != null &&
        widget.queryParameters['mode'] == 'preview') {
      if (!mounted) return;
      context.read<AppState>().isPreviewLock = true;
      context.read<AppState>().isPreview = true;
    }

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
      print('preview');
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

      // authentication completed

      if (widget.queryParameters['cmd'] != null &&
          widget.queryParameters['cmd'] == 'reset') {
        // deleting study progress
        print('subject id: $selectedStudyObjectId');
        if (selectedStudyObjectId != null) {
          try {
            final StudySubject subject =
            await SupabaseQuery.getById<StudySubject>(
              selectedStudyObjectId,
              selectedColumns: [
                '*',
                'study!study_subject_studyId_fkey(*)',
                'subject_progress(*)',
              ],
            );
            subject.delete();
            deleteActiveStudyReference();
            selectedStudyObjectId = await getActiveSubjectId();
            print('after deletion: $selectedStudyObjectId');
            selectedStudyObjectId = null;
            print('successfully deleted');
          } catch (e) {
            print('error with deleting: $e');
          }
        }
      }

      // Using the user session of the designer for the app preview interferes with the subscribed study of the user
      // --> WORKAROUND host the preview app version under a separate domain than the actual app!
      // e.g. normal app runs at app.studyu.health and preview version at preview.app.studyu.health
      // Preview version can be the same version as the app, since we use ?mode=preview to differentiate
      // between normal and preview use. The only importance is to have a different domain with different local storage
      // Thus the same user can also take part in studies on his own device and we do not have to work using anonymous accounts

      // old stuff:
      // we will use test accounts for study preview that can be deleted after the  study goes live
      // for this grant this account rights to access to the draft study
      // to do: send the anonymous account back to the designer and store the data somewhere with the creation data of the study
      //final success = await anonymousSignUp();

      StudySubject subject;

      if (selectedStudyObjectId != null) {
        print('Found subject id in shared prefs: $selectedStudyObjectId');
        // found study subject
        try {
          subject = await SupabaseQuery.getById<StudySubject>(
            selectedStudyObjectId,
            selectedColumns: [
              '*',
              'study!study_subject_studyId_fkey(*)',
              'subject_progress(*)',
            ],
          );
          // user is already subscribed to a study
          model.activeSubject = subject;
          print('equal check: ${subject.studyId} ${study.id}');
          if (subject.studyId == study.id) {
            // user is subscribed to the currently shown study
            print('go to dashboard');
            if (!mounted) return;
            context.read<AppState>().isPreviewLock = false;
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
        } catch(e) {
          print('could not load subject id');
        }

      }
      // user still has to subscribe to the study
      print('go to studyOverview');
      if (!mounted) return;
      context.read<AppState>().isPreviewLock = false;
      print('studyOverview');
      Navigator.pushReplacementNamed(context, Routes.studyOverview);
      return;
    } else if (!context.read<AppState>().isPreviewLock) {
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
        print('no preview dashboard');
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else {
        print('no preview welcome');
        Navigator.pushReplacementNamed(context, Routes.welcome);
      }
    } else {
      print('Nix');
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
