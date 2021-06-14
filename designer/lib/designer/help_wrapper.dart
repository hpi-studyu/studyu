import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DesignerHelpWrapper extends StatelessWidget {
  final String helpTitle;
  final String helpText;
  final bool studyPublished;
  final Widget child;

  const DesignerHelpWrapper(
      {Key key, @required this.helpTitle, @required this.helpText, @required this.child, @required this.studyPublished})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (studyPublished)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context).view_mode_warning,
              style: TextStyle(color: Colors.red),
            ),
          ),
        Row(children: [
          Spacer(),
          IconButton(icon: Icon(Icons.help), onPressed: () => _showHelpDialog(context, helpTitle, helpText))
        ]),
        Expanded(child: child),
      ],
    );
  }

  Future<void> _showHelpDialog(BuildContext context, String helpTitle, String helpText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(helpTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(helpText, overflow: TextOverflow.clip),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
