import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/study/contact.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/retry_future_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/app_state.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Future<Contact> appSupportContactFuture;
  Contact studyContact;

  @override
  void initState() {
    super.initState();
    appSupportContactFuture = getParseConfigContact();
    studyContact = context.read<AppState>().activeStudy?.contact;
  }

  Future<Contact> getParseConfigContact() async {
    final configs = await ParseConfig().getConfigs();
    return Contact.fromJson(configs.result['contact']);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).contact),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Image(
              image: AssetImage('assets/images/icon_wide.png'),
              height: 80,
            ),
          ),
          RetryFutureBuilder<Contact>(
              tryFunction: getParseConfigContact,
              successBuilder: (context, appSupportContact) => ContactWidget(
                    contact: appSupportContact,
                    title: AppLocalizations.of(context).app_support,
                    subtitle: AppLocalizations.of(context).app_support_text,
                    color: theme.primaryColor,
                  )),
          SizedBox(height: 20),
          ContactWidget(
            contact: studyContact,
            title: AppLocalizations.of(context).study_support,
            subtitle: AppLocalizations.of(context).study_support_text,
            color: theme.accentColor,
          ),
        ],
      ),
    );
  }
}

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final String title;
  final String subtitle;
  final Color color;

  const ContactWidget({@required this.contact, @required this.title, @required this.color, this.subtitle, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (contact == null) {
      return Container();
    }

    final titles = [Text(title, style: theme.textTheme.headline6.copyWith(color: color))];
    if (subtitle != null && subtitle.isNotEmpty) {
      titles.add(Text(subtitle, style: theme.textTheme.subtitle1.copyWith(fontSize: 14)));
    }

    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: titles,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context).organization,
          itemValue: contact?.organization,
          iconData: MdiIcons.hospitalBuilding,
          iconColor: color,
        ),
        if (contact?.institutionalReviewBoard != null)
          ContactItem(
            itemName: AppLocalizations.of(context).irb,
            itemValue: contact.institutionalReviewBoard + (contact?.institutionalReviewBoardNumber != null
                ? ': ${contact?.institutionalReviewBoardNumber}'
                : ''),
            iconData: MdiIcons.clipboardCheck,
            iconColor: color,
          ),
        ContactItem(
          itemName: AppLocalizations.of(context).researchers,
          itemValue: contact?.researchers,
          iconData: MdiIcons.doctor,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context).website,
          itemValue: contact?.website,
          iconData: MdiIcons.web,
          type: ContactItemType.website,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context).email,
          itemValue: contact?.email,
          iconData: MdiIcons.email,
          type: ContactItemType.email,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context).phone,
          itemValue: contact?.phone,
          iconData: MdiIcons.phone,
          type: ContactItemType.phone,
          iconColor: color,
        ),
      ],
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

  void launchContact() {
    {
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
  }

  @override
  Widget build(BuildContext context) {
    if (itemValue == null || itemValue.isEmpty) return Container();

    const iconSize = 40.0;
    return ListTile(
      title: Text(itemName),
      subtitle: SelectableText(itemValue),
      leading: Icon(iconData, color: iconColor ?? Theme.of(context).primaryColor, size: iconSize),
      onTap: type != null ? launchContact : null,
    );
  }
}
