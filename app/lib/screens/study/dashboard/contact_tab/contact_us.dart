import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/study/contact.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/app_state.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Contact contact;

  @override
  void initState() {
    super.initState();
    contact = context.read<AppState>().appSupportContact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Image(
                image: AssetImage('assets/images/icon_wide.png'),
                width: double.infinity,
                //height: 200,
                //fit: BoxFit.cover,
              ),
            ),
            ContactItem(
              itemName: 'Organization',
              itemValue: contact?.organization,
              iconData: MdiIcons.hospitalBuilding,
            ),
            ContactItem(
              itemName: 'Researchers',
              itemValue: contact?.researchers,
              iconData: MdiIcons.doctor,
            ),
            ContactItem(
              itemName: 'Website',
              itemValue: contact?.website,
              iconData: MdiIcons.web,
              type: ContactItemType.website,
            ),
            ContactItem(
              itemName: 'Email',
              itemValue: contact?.email,
              iconData: MdiIcons.email,
              type: ContactItemType.email,
            ),
            ContactItem(
              itemName: 'Phone',
              itemValue: contact?.phone,
              iconData: MdiIcons.phone,
              type: ContactItemType.phone,
            ),
          ],
        ),
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

  const ContactItem({@required this.itemName, @required this.itemValue, @required this.iconData, this.type, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconSize = 40.0;
    return Visibility(
      visible: itemValue != null && itemValue.isNotEmpty,
      child: ListTile(
        title: Text(itemName),
        subtitle: SelectableText(itemValue ?? ''),
        leading: Icon(iconData, color: Theme.of(context).primaryColor, size: iconSize),
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
