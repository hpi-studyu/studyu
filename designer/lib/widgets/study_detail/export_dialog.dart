import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer/util/result_downloader.dart';

import '../../theme.dart';

class ExportDialog extends StatefulWidget {
  final Study study;

  const ExportDialog({Key key, @required this.study}) : super(key: key);

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _includeParticipantData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> downloadFormattedResults() async {
    final dl = ResultDownloader(study: widget.study);
    final results = await dl.loadAllResults();
    for (final entry in results.entries) {
      downloadFile(ListToCsvConverter().convert(entry.value), '${widget.study.id}.${entry.key.filename}.csv');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Export data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Study Model'),
                SizedBox(width: 32),
                Checkbox(
                  value: _includeParticipantData,
                  onChanged: (value) => setState(() => _includeParticipantData = value),
                ),
                GestureDetector(
                  onTap: () => setState(() => _includeParticipantData = !_includeParticipantData),
                  child: Text('Include participant data'),
                ),
                SizedBox(width: 32),
                Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    final res = await env.client
                        .from(Study.tableName)
                        .select([
                          '*',
                          'study_participant_count',
                          'study_ended_count',
                          'active_subject_count',
                          'study_missed_days',
                          if (_includeParticipantData) 'study_subject(*, subject_progress(*))',
                        ].join(','))
                        .eq('id', widget.study.id)
                        .single()
                        .execute();
                    if (res.error != null) {
                      print(res.error.message);
                    }
                    await downloadFile(prettyJson(res.data),
                        _includeParticipantData ? 'study_model_with_participant_data.json' : 'study_model.json');
                  },
                  icon: Icon(MdiIcons.fileDownload, color: Color(0xff323330)),
                  label: Column(
                    children: [
                      Text('JSON', style: TextStyle(color: Color(0xff323330))),
                      Text('Recommended', style: TextStyle(color: accentColor, fontSize: 10))
                    ],
                  ),
                ),
                if (!_includeParticipantData) SizedBox(width: 8),
                if (!_includeParticipantData)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final res = await env.client
                          .from(Study.tableName)
                          .select([
                            '*',
                            'study_participant_count',
                            'study_ended_count',
                            'active_subject_count',
                            'study_missed_days',
                          ].join(','))
                          .eq('id', widget.study.id)
                          .csv()
                          .execute();
                      if (res.error != null) {
                        print(res.error.message);
                      }
                      await downloadFile(res.data, 'study_model.csv');
                    },
                    icon: Icon(MdiIcons.tableArrowDown, color: Colors.green),
                    label: Text('CSV', style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
            if (!_includeParticipantData) SizedBox(height: 16),
            if (!_includeParticipantData)
              Row(
                children: [
                  Text('Participant Data'),
                  Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final res = await env.client
                          .from(StudySubject.tableName)
                          .select('*,subject_progress(*)')
                          .eq('study_id', widget.study.id)
                          .execute();
                      if (res.error != null) {
                        print(res.error.message);
                      }
                      await downloadFile(prettyJson(res.data), 'participant_data.json');
                    },
                    icon: Icon(MdiIcons.fileDownload, color: Color(0xff323330)),
                    label: Text('JSON', style: TextStyle(color: Color(0xff323330))),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async =>
                        downloadFile(await Study.fetchResultsCSVTable(widget.study.id), 'participant_data.csv'),
                    icon: Icon(MdiIcons.tableArrowDown, color: Colors.green),
                    label: Column(
                      children: [
                        Text('CSV', style: TextStyle(color: Colors.green)),
                        Text('Recommended', style: TextStyle(color: accentColor, fontSize: 10))
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => downloadFormattedResults(),
              icon: Icon(MdiIcons.tableArrowDown, color: Colors.green),
              label: Text('Formatted CSV files as defined in Results', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      );
}
