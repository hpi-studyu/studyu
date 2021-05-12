import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';

import '../../models/app_state.dart';
import '../../util/storage_helper.dart';

class NotebookOverview extends StatelessWidget {
  final String studyId;

  const NotebookOverview({@required this.studyId, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RetryFutureBuilder<List<FileObject>>(
      tryFunction: () => getStudyNotebooks(studyId),
      successBuilder: (_, notebooks) {
        if (notebooks.isEmpty) {
          return Center(
            child: Text('No analytics available'),
          );
        }

        return Center(
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) => Divider(),
            itemCount: notebooks.length,
            itemBuilder: (context, index) => ListTile(
              leading: Icon(MdiIcons.languagePython, color: theme.accentColor),
              trailing: Icon(Icons.arrow_forward),
              title: Center(
                  child: Text(notebooks[index].name.replaceAll(RegExp(r'\.\w*$'), ''),
                      style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor))),
              onTap: () => context.read<AppState>().openNotebook(studyId, notebooks[index].name),
            ),
          ),
        );
      },
    );
  }
}
