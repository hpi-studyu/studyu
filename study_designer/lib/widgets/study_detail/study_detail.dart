import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu_designer/util/result_downloader.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../analytics/notebook_overview.dart';
import '../../models/app_state.dart';
import '../../util/repo_manager.dart';

class StudyDetails extends StatelessWidget {
  final String studyId;

  const StudyDetails(this.studyId, {Key key}) : super(key: key);

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
            tryFunction: () => SupabaseQuery.getById<Study>(studyId, selectedColumns: ['*', 'repo(*)']),
            successBuilder: (context, study) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Header(study: study),
                SizedBox(height: 32),
                Text('Gitlab Analysis Project', style: theme.textTheme.headline6),
                SizedBox(height: 8),
                AnalysisProjectOverview(study: study),
                Text('Notebooks', style: theme.textTheme.headline6),
                SizedBox(height: 8),
                NotebookOverview(studyId: study.id),
              ],
            ),
          )),
    );
  }
}

class Header extends StatelessWidget {
  final Study study;

  const Header({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Row(
          children: [
            Icon(MdiIcons.fromString(study.iconName), color: theme.accentColor),
            SizedBox(width: 8),
            Text(study.title, style: theme.textTheme.headline6.copyWith(color: theme.accentColor)),
          ],
        ),
        Spacer(),
        ButtonBar(
          children: [
            TextButton.icon(
                onPressed: () => context.read<AppState>().openDesigner(study.id),
                icon: Icon(Icons.edit),
                label: Text('Edit')),
            TextButton.icon(
                onPressed: () async {
                  final dl = ResultDownloader(study: study);
                  final results = await dl.loadAllResults();
                  for (final entry in results.entries) {
                    downloadFile(ListToCsvConverter().convert(entry.value), '${study.id}.${entry.key.filename}.csv');
                  }
                },
                icon: Icon(MdiIcons.tableArrowDown),
                label: Text(AppLocalizations.of(context).export_csv)),
          ],
        ),
      ],
    );
  }
}

class AnalysisProjectOverview extends StatefulWidget {
  final Study study;

  const AnalysisProjectOverview({@required this.study, Key key}) : super(key: key);

  @override
  _AnalysisProjectOverviewState createState() => _AnalysisProjectOverviewState();
}

class _AnalysisProjectOverviewState extends State<AnalysisProjectOverview> {
  bool _creatingRepo = false;

  @override
  Widget build(BuildContext context) {
    if (_creatingRepo) return CircularProgressIndicator();

    if (widget.study.repo == null) {
      return TextButton.icon(
        icon: Icon(MdiIcons.git, color: Color(0xfff1502f)),
        label: Text('Create analysis project'),
        onPressed: () async {
          setState(() {
            _creatingRepo = true;
          });
          await generateRepo(widget.study.id);
          context.read<AppState>().reloadStudies();
          setState(() {
            _creatingRepo = false;
          });
        },
      );
    }

    return Row(
      children: [
        SelectableText(widget.study.repo?.projectId),
        Spacer(),
        ButtonBar(
          children: [
            TextButton.icon(
                onPressed: () {
                  launch('https://gitlab.com/projects/${widget.study.repo?.projectId}');
                },
                icon: Icon(MdiIcons.gitlab, color: const Color(0xfffc6d26)),
                label: Text('Open Gitlab project')),
            TextButton.icon(
              icon: Icon(MdiIcons.databaseRefresh, color: Colors.green),
              label: Text('Update data of git project and notebooks'),
              onPressed: () => updateRepo(widget.study.id, widget.study.repo.projectId),
            ),
          ],
        ),
      ],
    );
  }
}
