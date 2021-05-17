import 'package:flutter/material.dart';
import 'package:studyou_core/core.dart';

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
