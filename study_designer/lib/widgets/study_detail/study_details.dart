import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu_designer/util/result_downloader.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_state.dart';
import '../../theme.dart';
import '../../util/repo_manager.dart';
import '../icon_labels.dart';
import 'notebook_overview.dart';

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
      getStudy = () => SupabaseQuery.getById<Study>(widget.studyId,
          selectedColumns: ['*', 'repo(*)', 'study_invite!study_invite_studyId_fkey(*)']);
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

  Widget gitOwnerActions() {
    if (widget.study.repo == null) {
      return TextButton.icon(
        icon: _loading ? buttonProgressIndicator : Icon(MdiIcons.git, color: Color(0xfff1502f)),
        label: Text('Create analysis project', style: TextStyle(color: Color(0xfff1502f))),
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
      );
    } else {
      return TextButton.icon(
        icon: _loading ? buttonProgressIndicator : Icon(MdiIcons.databaseRefresh, color: Colors.green),
        label: Text('Update data of git project and notebooks', style: TextStyle(color: Colors.green)),
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
      );
    }
  }

  List<Widget> gitPublicActions() {
    return [
      TextButton.icon(
          onPressed: () => launch('https://gitlab.com/projects/${widget.study.repo.projectId}'),
          icon: Icon(MdiIcons.gitlab, color: gitlabColor),
          label: Text('Open Gitlab project', style: TextStyle(color: gitlabColor))),
      TextButton.icon(
          onPressed: () async {
            final res = await http.get(Uri.parse('https://gitlab.com/api/v4/projects/${widget.study.repo.projectId}'));
            final encodedRepoUrl =
                Uri.encodeComponent((jsonDecode(res.body) as Map<String, dynamic>)['http_url_to_repo'] as String);
            await launch('https://mybinder.org/v2/git/$encodedRepoUrl/HEAD?urlpath=lab');
          },
          icon: Image.asset('assets/images/binder.png', height: 24, width: 24),
          label: Text('Launch on Binder')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Row(
              children: [
                Icon(MdiIcons.fromString(widget.study.iconName), color: theme.accentColor),
                SizedBox(width: 8),
                Text(widget.study.title, style: theme.textTheme.headline6.copyWith(color: theme.accentColor)),
                SizedBox(width: 16),
                if (widget.study.isOwner(appState.userId))
                  if (widget.study.published) publishedIcon() else draftIcon()
                else if (widget.study.participation == Participation.open)
                  openParticipationIcon()
                else
                  inviteParticipationIcon(),
              ],
            ),
            Spacer(),
            ButtonBar(
              buttonPadding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (appState.loggedIn && widget.study.isOwner(appState.userId))
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
                if (appState.loggedIn &&
                    widget.study.isOwner(appState.userId) &&
                    widget.study.participation == Participation.invite)
                  TextButton.icon(
                      onPressed: () async {
                        await showDialog(context: context, builder: (_) => InvitesDialog(study: widget.study));
                        widget.reload();
                      },
                      icon: Icon(MdiIcons.ticketAccount),
                      label: Text('Invite codes (${widget.study.invites.length})')),
                if (widget.study.repo != null) ...gitPublicActions(),
                if (appState.loggedInViaGitlab) gitOwnerActions(),
                if (widget.study.isOwner(appState.userId))
                  TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(AppLocalizations.of(context).delete, style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      final isDeleted = await showDialog<bool>(
                          context: context, builder: (_) => DeleteAlertDialog(study: widget.study));
                      if (isDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${widget.study.title} ${AppLocalizations.of(context).deleted}')));
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        if (widget.study.isOwner(appState.userId))
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Spacer(flex: 5),
                Expanded(
                  //width: 180,
                  child: DropdownButtonFormField<Participation>(
                    decoration: const InputDecoration(helperText: 'Participation'),
                    value: widget.study.participation,
                    onChanged: (value) async {
                      widget.study.participation = value;
                      await widget.study.save();
                      widget.reload();
                    },
                    items: [
                      DropdownMenuItem(
                        value: Participation.open,
                        child: openParticipationIcon(),
                      ),
                      DropdownMenuItem(
                        value: Participation.invite,
                        child: inviteParticipationIcon(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ResultSharing>(
                    decoration: const InputDecoration(helperText: 'Result sharing'),
                    value: widget.study.resultSharing,
                    onChanged: (value) async {
                      widget.study.resultSharing = value;
                      await widget.study.save();
                      widget.reload();
                    },
                    items: [
                      DropdownMenuItem(
                        value: ResultSharing.public,
                        child: publicResultsIcon(),
                      ),
                      DropdownMenuItem(
                        value: ResultSharing.private,
                        child: privateResultsIcon(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final Study study;

  const DeleteAlertDialog({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete_draft_study),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await study.delete();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.delete),
            label: Text(AppLocalizations.of(context).delete),
            style: ElevatedButton.styleFrom(primary: Colors.red, elevation: 0),
          )
        ],
      );
}

const buttonProgressIndicator = SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3));

class InvitesDialog extends StatefulWidget {
  final Study study;

  const InvitesDialog({Key key, @required this.study}) : super(key: key);

  @override
  _InvitesDialogState createState() => _InvitesDialogState();
}

class _InvitesDialogState extends State<InvitesDialog> {
  TextEditingController _controller;
  FocusNode _codeInputFocusNode;
  List<StudyInvite> _invites;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _invites = widget.study.invites;
    _controller = TextEditingController();
    _codeInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _codeInputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> addNewInviteCode(String code) async {
    if (_formKey.currentState.validate()) {
      final invite = await StudyInvite(code, widget.study.id).save();
      setState(() {
        _invites.add(invite);
      });
      _controller.clear();
      _codeInputFocusNode.requestFocus();
    }
  }

  Future<void> deleteInviteCode(StudyInvite invite) async {
    await invite.delete();
    setState(() {
      _invites.remove(invite);
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: Text('Invite Codes'),
        content: SizedBox(
          height: 500,
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _invites.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: SelectableText(_invites[index].code),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteInviteCode(_invites[index]),
                          ));
                    }),
              ),
              Form(
                key: _formKey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextFormField(
                        autofocus: true,
                        focusNode: _codeInputFocusNode,
                        controller: _controller,
                        decoration: InputDecoration(labelText: 'New invite code'),
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'Code should at least contain 4 characters';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => addNewInviteCode(value),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () => addNewInviteCode(_controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      );
}
