import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/models/app_state.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'header.dart';
import 'notebook_overview.dart';
import 'stats.dart';

class StudyDetails extends StatefulWidget {
  final String studyId;

  const StudyDetails(this.studyId, {Key key}) : super(key: key);

  @override
  _StudyDetailsState createState() => _StudyDetailsState();
}

class _StudyDetailsState extends State<StudyDetails> {
  Future<Study> Function() getStudy;

  @override
  void initState() {
    super.initState();
    reloadPage();
  }

  void reloadPage() {
    setState(() {
      getStudy = () => SupabaseQuery.getById<Study>(
            widget.studyId,
            selectedColumns: [
              '*',
              'repo(*)',
              'study_invite!study_invite_studyId_fkey(*)',
              'study_participant_count',
              'study_ended_count',
              'active_subject_count',
              'study_missed_days'
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return RetryFutureBuilder<Study>(
      tryFunction: getStudy,
      successBuilder: (context, study) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Header(study: study, reload: reloadPage),
                    const SizedBox(height: 8),
                    Stats(study: study, reload: reloadPage),
                    const SizedBox(height: 8),
                    NotebookOverview(studyId: study.id),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => appState.openDesigner(study.id),
            label: Text(study.canEdit(appState.user) ? 'Edit study' : 'View study'),
            icon: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
