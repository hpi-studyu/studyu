import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/notifications.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionString;

  const LoadingScreen({Key key, this.sessionString}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await UserQueries.recoverParticipantSession(sessionString: widget.sessionString);
    initStudy();
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>();
    final selectedStudyObjectId = await UserQueries.getActiveStudyObjectId();
    print('Selected study: $selectedStudyObjectId');
    if (selectedStudyObjectId == null) {
      if (UserQueries.isUserLoggedIn()) {
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }
    StudySubject subject;
    try {
      subject = await SupabaseQuery.getById<StudySubject>(selectedStudyObjectId, selectedColumns: [
        '*',
        'study!study_subject_studyId_fkey(*)',
        'subject_progress(*)',
      ]);
    } catch (e) {
      // Try signing in again. Needed if JWT is expired
      await UserQueries.signInParticipant();
      subject = await SupabaseQuery.getById<StudySubject>(selectedStudyObjectId, selectedColumns: [
        '*',
        'study!study_subject_studyId_fkey(*)',
        'subject_progress(*)',
      ]);
    } finally {
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
                '${AppLocalizations.of(context).loading}...',
                style: Theme.of(context).textTheme.headline4,
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
