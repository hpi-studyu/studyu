import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
import '../../../util/user.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = context.read<AppLanguage>().appLocal;
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
            getDropdownRow(context),
            SizedBox(height: 20),
            Text(
              'Current Study',
            ),
            RaisedButton(
              color: theme.accentColor,
              onPressed: () => Navigator.pushNamed(context, Routes.dashboard),
              child: Text(
                'Lower back pain',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text('Previous Study'),
            RaisedButton(
              color: theme.accentColor,
              onPressed: () => Navigator.pushNamed(context, Routes.dashboard),
              child: Text(
                'Lower back pain',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            RaisedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => DeleteAlertDialog());
              },
              color: Colors.red,
              icon: Icon(Icons.delete),
              label: Text('Delete all data'),
            )
          ],
        ),
      ),
    );
  }
}

class DeleteAlertDialog extends StatefulWidget {
  @override
  _DeleteAlertDialogState createState() => _DeleteAlertDialogState();
}

class _DeleteAlertDialogState extends State<DeleteAlertDialog> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Delete all data?'),
        content: Text('You will not be able to restore your data.'),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              UserUtils.logout();
              await SharedPreferences.getInstance().then((prefs) => prefs.remove(UserUtils.selectedStudyObjectIdKey));
              Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (_) => false);
            }, // only logout and delete local parse data,
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text('Delete all data'),
          )
        ],
      );
}
