import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/util/result_downloader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      downloadFile(const ListToCsvConverter().convert(entry.value), '${widget.study.id}.${entry.key.filename}.csv');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Export data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Study Model'),
                const SizedBox(width: 32),
                Checkbox(
                  value: _includeParticipantData,
                  onChanged: (value) => setState(() => _includeParticipantData = value),
                ),
                GestureDetector(
                  onTap: () => setState(() => _includeParticipantData = !_includeParticipantData),
                  child: const Text('Include participant data'),
                ),
                const SizedBox(width: 32),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    final res = await Supabase.instance.client
                        .from(Study.tableName)
                        .select([
                          '*',
                          'study_participant_count',
                          'study_ended_count',
                          'active_subject_count',
                          'study_missed_days',
                          if (_includeParticipantData) 'study_subject(*, subject_progress(*))',
                        ].join(','),)
                        .eq('id', widget.study.id)
                        .single()
                        .execute();
                    if (res.error != null) {
                      print(res.error.message);
                    }
                    await downloadFile(prettyJson(res.data),
                        _includeParticipantData ? 'study_model_with_participant_data.json' : 'study_model.json',);
                  },
                  icon: const Icon(MdiIcons.fileDownload, color: Color(0xff323330)),
                  label: Column(
                    children: const [
                      Text('JSON', style: TextStyle(color: Color(0xff323330))),
                      Text('Recommended', style: TextStyle(color: accentColor, fontSize: 10))
                    ],
                  ),
                ),
                if (!_includeParticipantData) const SizedBox(width: 8),
                if (!_includeParticipantData)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final res = await Supabase.instance.client
                          .from(Study.tableName)
                          .select([
                            '*',
                            'study_participant_count',
                            'study_ended_count',
                            'active_subject_count',
                            'study_missed_days',
                          ].join(','),)
                          .eq('id', widget.study.id)
                          .csv()
                          .execute();
                      if (res.error != null) {
                        print(res.error.message);
                      }
                      await downloadFile(res.data as String, 'study_model.csv');
                    },
                    icon: const Icon(MdiIcons.tableArrowDown, color: Colors.green),
                    label: const Text('CSV', style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
            if (!_includeParticipantData) const SizedBox(height: 16),
            if (!_includeParticipantData)
              Row(
                children: [
                  const Text('Participant Data'),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final res = await Supabase.instance.client
                          .from(StudySubject.tableName)
                          .select('*,subject_progress(*)')
                          .eq('study_id', widget.study.id)
                          .execute();
                      if (res.error != null) {
                        print(res.error.message);
                      }
                      await downloadFile(prettyJson(res.data), 'participant_data.json');
                    },
                    icon: const Icon(MdiIcons.fileDownload, color: Color(0xff323330)),
                    label: const Text('JSON', style: TextStyle(color: Color(0xff323330))),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async =>
                        downloadFile(await Study.fetchResultsCSVTable(widget.study.id), 'participant_data.csv'),
                    icon: const Icon(MdiIcons.tableArrowDown, color: Colors.green),
                    label: Column(
                      children: const [
                        Text('CSV', style: TextStyle(color: Colors.green)),
                        Text('Recommended', style: TextStyle(color: accentColor, fontSize: 10))
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: downloadFormattedResults,
              icon: const Icon(MdiIcons.tableArrowDown, color: Colors.green),
              label: const Text('Formatted CSV files as defined in Results', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      );
}
