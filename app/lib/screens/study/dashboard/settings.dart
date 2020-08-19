import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/user.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale _selectedValue;
  Future<ParseUser> _userFuture;
  ParseUserStudy activeStudy;

  @override
  void initState() {
    super.initState();
    _selectedValue = context.read<AppLanguage>().appLocal;
    _userFuture = UserQueries.getOrCreateUser();
    activeStudy = context.read<AppModel>().activeStudy;
  }

  Widget getDropdownRow(BuildContext context) {
    final dropDownItems = <DropdownMenuItem<Locale>>[];

    for (final locale in AppLanguage.supportedLocales) {
      dropDownItems.add(DropdownMenuItem(
        value: locale,
        child: Text(Nof1Localizations.of(context).translate(locale.languageCode)),
      ));
    }

    dropDownItems.add(DropdownMenuItem(
      value: null,
      child: Text('System'),
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("${Nof1Localizations.of(context).translate("language")}:"),
        SizedBox(
          width: 5,
        ),
        DropdownButton(
          value: _selectedValue,
          items: dropDownItems,
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
            context.read<AppLanguage>().changeLanguage(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('settings')),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FutureBuilder<ParseUser>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  final user = snapshot.data;
                  return SelectableText('User ID: ${user.username}');
                }),
            getDropdownRow(context),
            SizedBox(height: 24),
            Text('${Nof1Localizations.of(context).translate('study_current')} ${activeStudy.title}',
                style: theme.textTheme.headline6),
            SizedBox(height: 8),
            RaisedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => OptOutAlertDialog(activeStudy: activeStudy));
              },
              color: Colors.orange[800],
              icon: Icon(MdiIcons.exitToApp),
              label: Text(Nof1Localizations.of(context).translate('opt_out')),
            ),
            SizedBox(height: 24),
            RaisedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => DeleteAlertDialog());
              },
              color: Colors.red,
              icon: Icon(Icons.delete),
              label: Text(Nof1Localizations.of(context).translate('delete_data')),
            )
          ],
        ),
      ),
    );
  }
}

class OptOutAlertDialog extends StatelessWidget {
  final ParseUserStudy activeStudy;

  const OptOutAlertDialog({@required this.activeStudy}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Opt-out of study?'),
      content: RichText(
        text: TextSpan(style: TextStyle(color: Colors.black), children: [
          TextSpan(text: 'The progress of your current study '),
          TextSpan(
              text: activeStudy.title,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: ' will be deleted and cannot be recovered. Previously completed studies will not be deleted.'),
        ]),
      ),
      actions: [
        FlatButton.icon(
          onPressed: () async {
            activeStudy.delete();
            await SharedPreferences.getInstance().then((prefs) => prefs.remove(UserQueries.selectedStudyObjectIdKey));
            Navigator.pushNamedAndRemoveUntil(context, Routes.studySelection, (_) => false);
          },
          icon: Icon(MdiIcons.exitToApp),
          color: Colors.orange[800],
          label: Text('Opt-out'),
        )
      ],
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Delete all data?'),
        content: Text(
            'You will not be able to restore your data. Parts of your anonymized data may still be used for research purposes.'),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              UserQueries.deleteUserAccount();
              await SharedPreferences.getInstance().then((prefs) => prefs.remove(UserQueries.selectedStudyObjectIdKey));
              Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (_) => false);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text('Delete all data'),
          )
        ],
      );
}
