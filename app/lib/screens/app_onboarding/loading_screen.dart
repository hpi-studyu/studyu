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
import 'preview.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionString;
  final Map<String, String> queryParameters;

  const LoadingScreen({Key key, this.sessionString, this.queryParameters}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends SupabaseAuthState<LoadingScreen> {
  Preview preview;
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final hasRecovered = await recoverSupabaseSession();
    if (!hasRecovered) {
      await Supabase.instance.client.auth.recoverSession(widget.sessionString);
    }

    preview = Preview(widget.queryParameters ?? {});

    if (preview.containsQueryPair('mode', 'preview')) {
      modifySelectedSubjectIdKey(preview: true);
      if (!mounted) return;
      context.read<AppState>().isPreview = true;
      context.read<AppState>().previewInit = true;
    }
    initStudy();
    //print('returned from initStudy');
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>();
    await preview.init();
    if (!mounted) return;

    if (preview.containsQueryPair('mode', 'preview')) {
      if (!await preview.handleAuthorization()) return;
      model.selectedStudy = preview.study;

      // Authentication completed

      await preview.runCommands();

      final bool subscribed = await preview.isSubscribed();
      model.activeSubject = preview.subject;

      // check if user is subscribed to the currently shown study
      if (subscribed) {
        if (!mounted) return;
        context.read<AppState>().previewInit = false;
        Navigator.pushReplacementNamed(context, Routes.dashboard);
        return;
      }

      // user still has to subscribe to the study
      if (!mounted) return;
      context.read<AppState>().previewInit = false;
      Navigator.pushReplacementNamed(context, Routes.studyOverview);
      return;

    } else if (!context.read<AppState>().previewInit) {
      // non preview routes
      if (preview.selectedStudyObjectId == null) {
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
          preview.selectedStudyObjectId,
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
          preview.selectedStudyObjectId,
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
                '${AppLocalizations
                    .of(context)
                    .loading}...',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
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
