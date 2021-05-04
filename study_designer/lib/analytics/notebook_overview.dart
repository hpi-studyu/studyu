import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_designer/util/storage_helper.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';

import '../models/app_state.dart';

class NotebookOverview extends StatelessWidget {
  final String studyId;

  const NotebookOverview({@required this.studyId, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
      ),
      body: RetryFutureBuilder<List<FileObject>>(
        tryFunction: () => getStudyNotebooks(studyId),
        successBuilder: (_, notebooks) {
          if (notebooks.isEmpty) {
            return Center(
              child: Text('No analytics available'),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ListView(
                shrinkWrap: true,
                children: notebooks
                    .map((notebookFile) => ListTile(
                          title: Center(
                              child: Text(notebookFile.name,
                                  style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
                          onTap: () => context.read<AppState>().openAnalytics(studyId, notebook: notebookFile.name),
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
