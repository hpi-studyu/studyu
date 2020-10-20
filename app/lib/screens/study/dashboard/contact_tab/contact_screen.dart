import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/study/contact.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/app_state.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Contact appSupportContact;
  Contact studyContact;

  @override
  void initState() {
    super.initState();
    appSupportContact = context.read<AppState>().appSupportContact;
    print(appSupportContact);
    studyContact = context.read<AppState>().activeStudy.contact;
    print(studyContact);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Image(
              image: AssetImage('assets/images/icon_wide.png'),
              height: 80,
            ),
          ),
          Visibility(
              visible: appSupportContact != null,
              child: Column(
                children: [
                  Text('App support', style: theme.textTheme.headline6.copyWith(color: theme.primaryColor)),
                  Text('Contact for problems or questions with the app',
                      style: theme.textTheme.subtitle1.copyWith(fontSize: 14)),
                ],
              )),
          ContactItem(
            itemName: 'Organization',
            itemValue: appSupportContact?.organization,
            iconData: MdiIcons.hospitalBuilding,
          ),
          ContactItem(
            itemName: 'Researchers',
            itemValue: appSupportContact?.researchers,
            iconData: MdiIcons.doctor,
          ),
          ContactItem(
            itemName: 'Website',
            itemValue: appSupportContact?.website,
            iconData: MdiIcons.web,
            type: ContactItemType.website,
          ),
          ContactItem(
            itemName: 'Email',
            itemValue: appSupportContact?.email,
            iconData: MdiIcons.email,
            type: ContactItemType.email,
          ),
          ContactItem(
            itemName: 'Phone',
            itemValue: appSupportContact?.phone,
            iconData: MdiIcons.phone,
            type: ContactItemType.phone,
          ),
          SizedBox(height: 20),
          Visibility(
              visible: appSupportContact != null,
              child: Column(
                children: [
                  Text('Study support', style: theme.textTheme.headline6.copyWith(color: theme.accentColor)),
                  Text('Contact for problems or questions with the study',
                      style: theme.textTheme.subtitle1.copyWith(fontSize: 14)),
                ],
              )),
          ContactItem(
            itemName: 'Organization',
            itemValue: studyContact?.organization,
            iconData: MdiIcons.hospitalBuilding,
            iconColor: theme.accentColor,
          ),
          ContactItem(
            itemName: 'Researchers',
            itemValue: studyContact?.researchers,
            iconData: MdiIcons.doctor,
            iconColor: theme.accentColor,
          ),
          ContactItem(
            itemName: 'Website',
            itemValue: studyContact?.website,
            iconData: MdiIcons.web,
            type: ContactItemType.website,
            iconColor: theme.accentColor,
          ),
          ContactItem(
            itemName: 'Email',
            itemValue: studyContact?.email,
            iconData: MdiIcons.email,
            type: ContactItemType.email,
            iconColor: theme.accentColor,
          ),
          ContactItem(
            itemName: 'Phone',
            itemValue: studyContact?.phone,
            iconData: MdiIcons.phone,
            type: ContactItemType.phone,
            iconColor: theme.accentColor,
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('Contact Us')),
      ),
    );
  }
}

enum ContactItemType { website, email, phone }

class ContactItem extends StatelessWidget {
  final IconData iconData;
  final String itemName;
  final String itemValue;
  final ContactItemType type;
  final Color iconColor;

  const ContactItem(
      {@required this.itemName, @required this.itemValue, @required this.iconData, this.type, this.iconColor, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconSize = 40.0;
    return Visibility(
      visible: itemValue != null && itemValue.isNotEmpty,
      child: ListTile(
        title: Text(itemName),
        subtitle: SelectableText(itemValue ?? ''),
        leading: Icon(iconData, color: iconColor ?? Theme.of(context).primaryColor, size: iconSize),
        onTap: type != null
            ? () {
                switch (type) {
                  case ContactItemType.website:
                    if (!itemValue.startsWith('http://') && !itemValue.startsWith('https://')) {
                      launch('http://$itemValue');
                    } else {
                      launch(itemValue);
                    }
                    break;
                  case ContactItemType.email:
                    launch('mailto:$itemValue');
                    break;
                  case ContactItemType.phone:
                    launch('tel:$itemValue');
                    break;
                }
                launch(itemValue);
              }
            : null,
      ),
    );
  }
}
