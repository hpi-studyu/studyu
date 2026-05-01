import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Contact? studyContact;

  @override
  void initState() {
    super.initState();
    studyContact = context.read<AppState>().activeSubject?.study.contact;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.contact)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Image(
                image: AssetImage('assets/icon/logo.png'),
                height: 80,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RetryFutureBuilder<Contact>(
            tryFunction: AppConfig.getAppContact,
            successBuilder: (BuildContext context, Contact? appSupportContact) {
              if (appSupportContact == null) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ContactWidget(
                    contact: appSupportContact,
                    title: AppLocalizations.of(context)!.app_support,
                    subtitle: AppLocalizations.of(context)!.app_support_text,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
          if (studyContact != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ContactWidget(
                  contact: studyContact,
                  title: AppLocalizations.of(context)!.study_support,
                  subtitle: AppLocalizations.of(context)!.study_support_text,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ContactWidget extends StatelessWidget {
  final Contact? contact;
  final String title;
  final String? subtitle;
  final Color color;

  const ContactWidget({
    required this.contact,
    required this.title,
    required this.color,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (contact == null) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[
      Text(title, style: theme.textTheme.titleLarge!.copyWith(color: color)),
      if (subtitle != null && subtitle!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle!,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      const SizedBox(height: 12),
    ];

    final items = <Widget>[];

    void addItem({
      required String itemName,
      required String? itemValue,
      required IconData iconData,
      ContactItemType? type,
    }) {
      if (itemValue == null || itemValue.isEmpty) return;
      if (items.isNotEmpty) {
        items.add(const Divider(height: 1));
      }
      items.add(
        ContactItem(
          itemName: itemName,
          itemValue: itemValue,
          iconData: iconData,
          type: type,
        ),
      );
    }

    addItem(
      itemName: AppLocalizations.of(context)!.organization,
      itemValue: contact?.organization,
      iconData: MdiIcons.hospitalBuilding,
    );
    if (contact?.institutionalReviewBoard != null) {
      addItem(
        itemName: AppLocalizations.of(context)!.irb,
        itemValue:
            contact!.institutionalReviewBoard! +
            (contact?.institutionalReviewBoardNumber != null
                ? ': ${contact?.institutionalReviewBoardNumber}'
                : ''),
        iconData: MdiIcons.clipboardCheck,
      );
    }
    addItem(
      itemName: AppLocalizations.of(context)!.researchers,
      itemValue: contact?.researchers,
      iconData: MdiIcons.doctor,
    );
    addItem(
      itemName: AppLocalizations.of(context)!.website,
      itemValue: contact?.website,
      iconData: MdiIcons.web,
      type: ContactItemType.website,
    );
    addItem(
      itemName: AppLocalizations.of(context)!.email,
      itemValue: contact?.email,
      iconData: MdiIcons.email,
      type: ContactItemType.email,
    );
    addItem(
      itemName: AppLocalizations.of(context)!.phone,
      itemValue: contact?.phone,
      iconData: MdiIcons.phone,
      type: ContactItemType.phone,
    );
    if (contact?.additionalInfo != null) {
      addItem(
        itemName: AppLocalizations.of(context)!.additionalInfo,
        itemValue: contact!.additionalInfo,
        iconData: MdiIcons.information,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...children, ...items],
    );
  }
}

enum ContactItemType { website, email, phone }

class ContactItem extends StatelessWidget {
  final IconData iconData;
  final String itemName;
  final String? itemValue;
  final ContactItemType? type;
  final Color? iconColor;

  const ContactItem({
    required this.itemName,
    required this.itemValue,
    required this.iconData,
    this.type,
    this.iconColor,
    super.key,
  });

  Future<void> launchContact() async {
    Uri uri;
    switch (type) {
      case ContactItemType.website:
        if (!itemValue!.startsWith('http://') &&
            !itemValue!.startsWith('https://')) {
          uri = Uri.parse('http://$itemValue');
        } else {
          uri = Uri.parse(itemValue!);
        }
      case ContactItemType.email:
        uri = Uri.parse('mailto:$itemValue');
      case ContactItemType.phone:
        uri = Uri.parse('tel:$itemValue');
      default:
        uri = Uri.parse(itemValue!);
    }
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    } else {
      StudyULogger.warning("Cannot launch Url: $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemValue == null || itemValue!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return InkWell(
      onTap: type != null ? launchContact : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: iconColor ?? theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    itemValue!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (type != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
