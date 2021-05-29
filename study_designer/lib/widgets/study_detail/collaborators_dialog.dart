import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';

class AddCollaboratorDialog extends StatefulWidget {
  final Study study;

  const AddCollaboratorDialog({Key key, @required this.study}) : super(key: key);

  @override
  _AddCollaboratorDialogState createState() => _AddCollaboratorDialogState();
}

class _AddCollaboratorDialogState extends State<AddCollaboratorDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;
  FocusNode _emailInputFocusNode;
  String _emailErrorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _emailInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailInputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addNewCollaborator(String email) async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          widget.study
            ..collaboratorEmails.add(email)
            ..save();
          _emailErrorText = null;
        });
        _controller.clear();
        _emailInputFocusNode.requestFocus();
      } catch (e) {
        setState(() {
          _emailErrorText = 'An error occurred. Try a different code.';
        });
      }
    }
  }

  Future<void> _removeCollaborator(String email) async {
    setState(() {
      widget.study
        ..collaboratorEmails.remove(email)
        ..save();
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Collaborator emails'),
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
                    itemCount: widget.study.collaboratorEmails.length,
                    itemBuilder: (BuildContext context, int index) {
                      final email = widget.study.collaboratorEmails[index];
                      return ListTile(
                          leading: Icon(Icons.mail),
                          title: SelectableText(email),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCollaborator(email),
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
                        focusNode: _emailInputFocusNode,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'New collaborator email',
                          errorText: _emailErrorText,
                        ),
                        validator: (email) {
                          if (!EmailValidator.validate(email)) {
                            return 'Not a valid email';
                          } else if (widget.study.collaboratorEmails.contains(email)) {
                            return 'Email is already defined';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => _addNewCollaborator(value),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(MdiIcons.accountPlus, color: Colors.green),
                      onPressed: () => _addNewCollaborator(_controller.text),
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
