import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../util/localization.dart';

class AccountManagement extends StatefulWidget {
  @override
  _AccountManagementState createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  Locale _selectedValue;

  @override
  void didChangeDependencies() {
    _selectedValue = Provider.of<AppLanguage>(context, listen: false).appLocal;
    super.didChangeDependencies();
  }

  Widget getDropdownRow(BuildContext context) {
    final dropDownItems = <DropdownMenuItem<Locale>>[];

    for (var locale in AppLanguage.supportedLocales) {
      dropDownItems.add(DropdownMenuItem(
        child: Text(Nof1Localizations.of(context).translate(locale.languageCode)),
        value: locale,
      ));
    }

    dropDownItems.add(DropdownMenuItem(
      child: Text('System'),
      value: null,
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
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            getDropdownRow(context),
            Text('Peter'),
            SizedBox(height: 20),
            Text('Müller'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(MdiIcons.instagram),
                Icon(MdiIcons.facebook),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
