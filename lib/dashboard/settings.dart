import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/localization.dart';
import '../util/user.dart';
import 'dashboard.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale _selectedValue;

  @override
  void didChangeDependencies() {
    _selectedValue = Provider.of<AppLanguage>(context, listen: false).appLocal;
    super.didChangeDependencies();
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
            Provider.of<AppLanguage>(context, listen: false).changeLanguage(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              color: Colors.amber,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen())),
              child: Text(
                'Lower back pain',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 20),
            Text('Previous Study'),
            RaisedButton(
              color: Colors.amber,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen())),
              child: Text(
                'Lower back pain',
                style: TextStyle(fontSize: 16.0),
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
            onPressed: () {
              UserUtils.logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            }, // only logout and delete local parse data,
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text('Delete all data'),
          )
        ],
      );
}
