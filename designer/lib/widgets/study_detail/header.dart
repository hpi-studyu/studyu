import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/models/app_state.dart';
import 'package:studyu_designer/util/repo_manager.dart';
import 'package:studyu_designer/widgets/study_detail/collaborators_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../icon_labels.dart';
import 'export_dialog.dart';
import 'invites_dialog.dart';

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

  Widget _buildAccessSettings() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<Participation>(
            // decoration: const InputDecoration(helperText: 'Participation'),
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
          SizedBox(width: 16),
          DropdownButton<ResultSharing>(
            // decoration: const InputDecoration(helperText: 'Result sharing'),
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
          )
        ],
      ),
    );
  }

  Widget _buildAccessHeader({@required bool isOwner}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.study.published) publishedIcon() else draftIcon(),
        SizedBox(width: 16),
        if (isOwner)
          _buildAccessSettings()
        else if (widget.study.participation == Participation.open)
          Expanded(child: openParticipationIcon())
        else
          Expanded(child: inviteParticipationIcon()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(0, 0, 8, 0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackButton(),
            SizedBox(width: 8),
            Icon(MdiIcons.fromString(widget.study.iconName), color: theme.colorScheme.secondary),
            SizedBox(width: 8),
            Text(widget.study.title, style: theme.textTheme.headline6.copyWith(color: theme.colorScheme.secondary)),
            // VerticalDivider(indent: 8, endIndent: 8),
          ],
        ),
        title: IntrinsicHeight(
          child: _buildAccessHeader(isOwner: widget.study.canEdit(appState.user)),
        ),
        trailing: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
                onPressed: () async {
                  await showDialog(context: context, builder: (_) => ExportDialog(study: widget.study));
                },
                icon: Icon(MdiIcons.databaseExport),
                label: Text('Export Data')),
            if (widget.study.isOwner(appState.user))
              TextButton.icon(
                  onPressed: () async {
                    await showDialog(context: context, builder: (_) => AddCollaboratorDialog(study: widget.study));
                    widget.reload();
                  },
                  icon: Icon(MdiIcons.accountPlus),
                  label: Text('Add collaborator')),
            if (widget.study.canEdit(appState.user) && widget.study.participation == Participation.invite)
              TextButton.icon(
                  onPressed: () async {
                    await showDialog(context: context, builder: (_) => InvitesDialog(study: widget.study));
                    widget.reload();
                  },
                  icon: Icon(MdiIcons.ticketAccount),
                  label: Text('Invite codes (${widget.study.invites.length})')),
            if (widget.study.repo != null) ...gitPublicActions(),
            if (appState.loggedInViaGitlab && widget.study.isOwner(appState.user)) gitOwnerActions(),
            if (widget.study.canEdit(appState.user))
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text(AppLocalizations.of(context).delete, style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  final isDeleted =
                      await showDialog<bool>(context: context, builder: (_) => DeleteAlertDialog(study: widget.study));
                  if (isDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.study.title} ${AppLocalizations.of(context).deleted}')));
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

const buttonProgressIndicator = SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3));

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
