import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

import '../../theme.dart';

class InvitesDialog extends StatefulWidget {
  final Study study;

  const InvitesDialog({Key key, @required this.study}) : super(key: key);

  @override
  _InvitesDialogState createState() => _InvitesDialogState();
}

class _InvitesDialogState extends State<InvitesDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;
  FocusNode _codeInputFocusNode;
  String _codeErrorText;

  List<StudyInvite> _invites;
  bool _preselectInterventions = false;
  Intervention _interventionA;
  Intervention _interventionB;

  @override
  void initState() {
    super.initState();
    _invites = widget.study.invites;
    _controller = TextEditingController();
    _codeInputFocusNode = FocusNode();

    _interventionA = widget.study.interventions.first;
    _interventionB = widget.study.interventions.last;

    _preselectInterventions = _invites.any((invite) => invite.preselectedInterventionIds != null);
  }

  @override
  void dispose() {
    _codeInputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> addNewInviteCode(String code) async {
    if (_formKey.currentState.validate()) {
      StudyInvite invite;
      invite = StudyInvite(code, widget.study.id,
          preselectedInterventionIds: _preselectInterventions ? [_interventionA.id, _interventionB.id] : null);
      try {
        await invite.save();
        setState(() {
          _invites.add(invite);
          _codeErrorText = null;
        });
        _controller.clear();
        _codeInputFocusNode.requestFocus();
      } catch (e) {
        setState(() {
          _codeErrorText = 'An error occurred. Try a different code.';
        });
      }
    }
  }

  Future<void> deleteInviteCode(StudyInvite invite) async {
    await invite.delete();
    setState(() {
      _invites.remove(invite);
    });
  }

  Widget _buildSelectedInterventions(List<String> selectedInterventionIds) {
    final a = getIntervention(selectedInterventionIds[0]);
    final b = getIntervention(selectedInterventionIds[1]);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        Icon(MdiIcons.fromString(a.icon), color: theme.colorScheme.secondary),
        SizedBox(width: 8),
        Text(a.name, overflow: TextOverflow.ellipsis),
        Spacer(),
        Icon(MdiIcons.fromString(b.icon), color: theme.colorScheme.secondary),
        SizedBox(width: 8),
        Text(b.name, overflow: TextOverflow.ellipsis),
        Spacer(),
      ],
    );
  }

  Widget _buildIntervention(Intervention intervention) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(MdiIcons.fromString(intervention.icon), color: theme.colorScheme.secondary),
        SizedBox(width: 8),
        Expanded(child: Text(intervention.name, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Intervention getIntervention(String id) {
    return widget.study.interventions.firstWhere((i) => i.id == id);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invite codes (${_invites.length})'),
            Spacer(),
            Text('Preselect interventions (Order: ${widget.study.schedule.nameOfSequence})',
                style: Theme.of(context).textTheme.bodyText2),
            Switch(
              value: _preselectInterventions,
              onChanged: (value) => setState(() {
                _preselectInterventions = value;
              }),
            ),
          ],
        ),
        content: SizedBox(
          height: 600,
          width: 800,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _invites.length,
                    itemBuilder: (BuildContext context, int index) {
                      final invite = _invites[index];
                      return ListTile(
                          leading: SelectableText(invite.code),
                          title: invite.preselectedInterventionIds != null
                              ? _buildSelectedInterventions(invite.preselectedInterventionIds)
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteInviteCode(invite),
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
                        // Only enable autoFocus on web. Very annoying on mobile!
                        autofocus: kIsWeb,
                        focusNode: _codeInputFocusNode,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'New invite code',
                          errorText: _codeErrorText,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'Code should at least contain 4 characters';
                          } else if (_invites.map((e) => e.code).contains(value)) {
                            return 'Code is already defined';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => addNewInviteCode(value),
                      ),
                    ),
                    SizedBox(width: 16),
                    if (_preselectInterventions) ...[
                      Expanded(
                        child: DropdownButtonFormField<Intervention>(
                          validator: (value) {
                            if (value == _interventionB) return 'Same as Intervention B';
                            return null;
                          },
                          isExpanded: true,
                          decoration: InputDecoration(helperText: 'Intervention A'),
                          value: _interventionA,
                          onChanged: (value) => setState(() => _interventionA = value),
                          items: widget.study.interventions
                              .map((i) => DropdownMenuItem<Intervention>(
                                    value: i,
                                    child: _buildIntervention(i),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Intervention>(
                          validator: (value) {
                            if (value == _interventionA) return 'Same as Intervention A';
                            return null;
                          },
                          isExpanded: true,
                          decoration: InputDecoration(helperText: 'Intervention B'),
                          value: _interventionB,
                          onChanged: (value) => setState(() => _interventionB = value),
                          items: widget.study.interventions
                              .map((i) => DropdownMenuItem<Intervention>(
                                    value: i,
                                    child: _buildIntervention(i),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
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
