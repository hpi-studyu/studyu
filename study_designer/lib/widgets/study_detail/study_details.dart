import 'package:flutter/material.dart';
import 'package:studyou_core/core.dart';
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
      getStudy = () => SupabaseQuery.getById<Study>(widget.studyId, selectedColumns: [
            '*',
            'repo(*)',
            'study_invite!study_invite_studyId_fkey(*)',
            'study_participant_count',
            'study_completed_count',
            'active_subject_count'
          ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Overview'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: RetryFutureBuilder<Study>(
            tryFunction: getStudy,
            successBuilder: (context, study) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Header(study: study, reload: reloadPage),
                SizedBox(height: 8),
                Stats(study: study, reload: reloadPage),
                SizedBox(height: 8),
                NotebookOverview(studyId: study.id),
              ],
            ),
          )),
    );
  }
}
