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
    getStudy = () => SupabaseQuery.getById<Study>(widget.studyId, selectedColumns: ['*', 'repo(*)']);
  }

  void reloadPage() {
    setState(() {
      getStudy = () => SupabaseQuery.getById<Study>(widget.studyId, selectedColumns: ['*', 'repo(*)']);
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
                SizedBox(height: 32),
                Text('Notebooks', style: theme.textTheme.headline6),
                SizedBox(height: 8),
                NotebookOverview(studyId: study.id),
              ],
            ),
          )),
    );
  }
}

class Header extends StatefulWidget {
  final Study study;
  final Function() reload;

  const Header({@required this.study, this.reload, Key key}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Row(
          children: [
            Icon(MdiIcons.fromString(widget.study.iconName), color: theme.accentColor),
            SizedBox(width: 8),
            Text(widget.study.title, style: theme.textTheme.headline6.copyWith(color: theme.accentColor)),
          ],
        ),
        Spacer(),
        ButtonBar(
          children: [
            TextButton.icon(
                onPressed: () => context.read<AppState>().openDesigner(widget.study.id),
                icon: Icon(Icons.edit),
                label: Text('Edit')),
            TextButton.icon(
                onPressed: () async {
                  final dl = ResultDownloader(study: widget.study);
                  final results = await dl.loadAllResults();
                  for (final entry in results.entries) {
                    downloadFile(
                        ListToCsvConverter().convert(entry.value), '${widget.study.id}.${entry.key.filename}.csv');
                  }
                },
                icon: Icon(MdiIcons.tableArrowDown),
                label: Text(AppLocalizations.of(context).export_csv)),
            if (widget.study.repo == null)
              TextButton.icon(
                icon: _loading ? buttonProgressIndicator : Icon(MdiIcons.git, color: Color(0xfff1502f)),
                label: Text('Create analysis project'),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  try {
                    await generateRepo(widget.study.id);
                    widget.reload();
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      _loading = false;
                    });
                  }
                },
              )
            else ...[
              TextButton.icon(
                  onPressed: () => launch('https://gitlab.com/projects/${widget.study.repo.projectId}'),
                  icon: Icon(MdiIcons.gitlab, color: const Color(0xfffc6d26)),
                  label: Text('Open Gitlab project')),
              TextButton.icon(
                icon: _loading ? buttonProgressIndicator : Icon(MdiIcons.databaseRefresh, color: Colors.green),
                label: Text('Update data of git project and notebooks'),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  try {
                    await updateRepo(widget.study.id, widget.study.repo.projectId);
                    widget.reload();
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      _loading = false;
                    });
                  }
                },
              ),
            ]
          ],
        ),
      ],
    );
  }
}

const buttonProgressIndicator = SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3));
