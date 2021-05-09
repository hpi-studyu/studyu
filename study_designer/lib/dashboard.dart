import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/app_state.dart';
import 'util/localization.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Locale _selectedLocal;
  bool termsDialogAlreadyShown = false;

  @override
  void initState() {
    super.initState();
    _selectedLocal = context.read<AppLanguage>().appLocal;
    showTermsAndPrivacyDialog();
  }

  void showTermsAndPrivacyDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!termsDialogAlreadyShown && kReleaseMode) {
        setState(() {
          termsDialogAlreadyShown = true;
        });
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final appLocale = Localizations.localeOf(context);

              return RetryFutureBuilder<AppConfig>(
                tryFunction: AppConfig.getAppConfig,
                successBuilder: (BuildContext context, AppConfig appConfig) => AlertDialog(
                  title: Text(AppLocalizations.of(context).terms_privacy),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context).terms_agree),
                    )
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context).terms_content),
                      SizedBox(height: 20),
                      OutlinedButton.icon(
                        icon: Icon(MdiIcons.fileDocumentEdit),
                        onPressed: () => launch(appConfig.designer_terms[appLocale.toString()]),
                        label: Text(AppLocalizations.of(context).terms_read),
                      ),
                      OutlinedButton.icon(
                        icon: Icon(MdiIcons.shieldLock),
                        onPressed: () => launch(appConfig.designer_privacy[appLocale.toString()]),
                        label: Text(AppLocalizations.of(context).privacy_read),
                      ),
                    ],
                  ),
                ),
              );
            });
      }
    });
  }

  Widget _buildLanguageDropdown() {
    final dropDownItems = <DropdownMenuItem<Locale>>[];

    for (final locale in AppLocalizations.supportedLocales) {
      dropDownItems.add(DropdownMenuItem(
        value: locale,
        child: Text(localeName(context, locale.languageCode)),
      ));
    }

    dropDownItems.add(const DropdownMenuItem(
      child: Text('System'),
    ));

    return DropdownButton<Locale>(
      value: _selectedLocal,
      items: dropDownItems,
      onChanged: (value) {
        setState(() {
          _selectedLocal = value;
        });
        context.read<AppLanguage>().changeLanguage(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('StudyU Designer'),
        actions: [
          if (kDebugMode)
            Builder(builder: (context) {
              return Theme(
                data: ThemeData.dark(),
                child: TextButton.icon(
                  label: Text('Upload'),
                  icon: Icon(MdiIcons.upload),
                  style: TextButton.styleFrom(primary: Colors.white),
                  onPressed: () async {
                    final controller = TextEditingController();
                    final wasUploaded = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Paste Study JSON here'),
                        actions: [
                          TextButton.icon(
                            label: Text('Cancel'),
                            icon: Icon(MdiIcons.close),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                          TextButton.icon(
                            label: Text('Upload'),
                            icon: Icon(MdiIcons.upload),
                            onPressed: () {
                              try {
                                final studyJson = json.decode(controller.text) as Map<String, dynamic>;
                                Study.fromJson(studyJson).save();
                                Navigator.pop(context, true);
                              } on FormatException {
                                controller.text = 'This is not valid JSON! Please paste valid JSON.';
                              }
                            },
                          ),
                        ],
                        content: TextField(
                          controller: controller,
                          minLines: 100,
                          maxLines: 10000,
                        ),
                      ),
                    );
                    if (wasUploaded) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Successfully imported study JSON 🎉')));
                    }
                  },
                ),
              );
            }),
          Theme(
            data: ThemeData.dark(),
            child: DropdownButtonHideUnderline(
              child: _buildLanguageDropdown(),
            ),
          ),
          if (context.watch<AppState>().loggedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => context.read<AppState>().signOut(),
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () => context.read<AppState>().goToLoginScreen(),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RetryFutureBuilder<List<Study>>(
            tryFunction: context.watch<AppState>().researcherDashboardQuery,
            successBuilder: (BuildContext context, List<Study> studies) {
              final draftStudies = studies.where((s) => !s.published).toList();
              final publishedStudies = studies.where((s) => s.published).toList();
              return ListView(
                children: [
                  if (draftStudies.isNotEmpty)
                    ExpansionTile(
                      title: Row(children: [
                        Icon(Icons.edit, color: theme.accentColor),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context).draft_studies)
                      ]),
                      initiallyExpanded: true,
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: draftStudies.map((study) => StudyCard(
                                study: study,
                                reload: context.read<AppState>().reloadStudies,
                              ))).toList(),
                    ),
                  if (publishedStudies.isNotEmpty)
                    ExpansionTile(
                      title: Row(children: [
                        Icon(Icons.lock, color: theme.accentColor),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context).published_studies)
                      ]),
                      initiallyExpanded: true,
                      children: ListTile.divideTiles(
                          context: context,
                          tiles: publishedStudies.map((study) => StudyCard(
                                study: study,
                                reload: context.read<AppState>().reloadStudies,
                              ))).toList(),
                    )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: context.watch<AppState>().loggedIn
          ? FloatingActionButton(
              onPressed: () {
                context.read<AppState>().createStudy();
              },
              tooltip: 'Add',
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class StudyCard extends StatelessWidget {
  final Study study;
  final void Function() reload;

  const StudyCard({@required this.study, @required this.reload, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon =
        study.iconName != null && study.iconName.isNotEmpty ? MdiIcons.fromString(study.iconName) : MdiIcons.cropSquare;

    return ListTile(
        title: Text(study.title),
        subtitle: Text(study.description),
        leading: Icon(icon),
        trailing: !study.published
            ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final isDeleted =
                      await showDialog<bool>(context: context, builder: (_) => DeleteAlertDialog(study: study));
                  if (isDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).deleted}')));
                    if (reload != null) reload();
                  }
                },
              )
            : null,
        onTap: () => context.read<AppState>().openDetails(study.id));
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final Study study;

  const DeleteAlertDialog({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete_draft_study),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await study.delete();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.delete),
            label: Text(AppLocalizations.of(context).delete),
            style: ElevatedButton.styleFrom(primary: Colors.red, elevation: 0),
          )
        ],
      );
}
