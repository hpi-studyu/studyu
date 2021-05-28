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
import 'widgets/icon_labels.dart';

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
    final appState = context.watch<AppState>();
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
          if (appState.loggedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => appState.signOut(),
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () => appState.goToLoginScreen(),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RetryFutureBuilder<List<Study>>(
            tryFunction: appState.researcherDashboardQuery,
            successBuilder: (BuildContext context, List<Study> studies) {
              studies.sort(_sortStudies);
              final myStudies = studies.where((s) => s.isOwner(appState.userId));
              final publicStudies =
                  studies.where((s) => !s.isOwner(appState.userId) && s.resultSharing == ResultSharing.public);
              return ListView(
                children: [
                  if (myStudies.isNotEmpty)
                    Card(
                      child: ExpansionTile(
                        title: Row(children: [
                          Icon(MdiIcons.accountLock, color: theme.accentColor),
                          SizedBox(width: 8),
                          Text('My Studies')
                        ]),
                        initiallyExpanded: true,
                        children: ListTile.divideTiles(
                            context: context,
                            tiles: myStudies.map((study) => StudyCard(
                                  study: study,
                                  owner: study.isOwner(appState.userId),
                                  reload: appState.reloadStudies,
                                ))).toList(),
                      ),
                    ),
                  if (publicStudies.isNotEmpty)
                    Card(
                      child: ExpansionTile(
                        title: Row(children: [
                          Icon(MdiIcons.earth, color: theme.accentColor),
                          SizedBox(width: 8),
                          Text('Public studies')
                        ]),
                        initiallyExpanded: true,
                        children: ListTile.divideTiles(
                            context: context,
                            tiles: publicStudies.map((study) => StudyCard(
                                  study: study,
                                  owner: study.isOwner(appState.userId),
                                  reload: appState.reloadStudies,
                                ))).toList(),
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: appState.loggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                appState.createStudy();
              },
              label: Text('Create study'),
              icon: Icon(Icons.add),
            )
          : null,
    );
  }

  int _sortStudies(Study s1, Study s2) {
    if (s1.published == s2.published) {
      if (s1.resultSharing == s2.resultSharing) {
        return s1.participation.toString().compareTo(s2.participation.toString());
      }
      return s1.resultSharing.toString().compareTo(s2.resultSharing.toString());
    }
    return s1.published.toString().compareTo(s2.published.toString());
  }
}

class StudyCard extends StatelessWidget {
  final Study study;
  final void Function() reload;
  final bool owner;

  const StudyCard({@required this.study, @required this.owner, @required this.reload, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon =
        study.iconName != null && study.iconName.isNotEmpty ? MdiIcons.fromString(study.iconName) : MdiIcons.cropSquare;

    return ListTile(
        title: Text(study.title),
        subtitle: Text(study.description),
        leading: Icon(icon),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconLabel(label: study.participantCount.toString(), iconData: MdiIcons.accountGroup, color: Colors.red),
            SizedBox(width: 16),
            IconLabel(label: study.endedCount.toString(), iconData: MdiIcons.flagCheckered, color: Colors.black),
            SizedBox(width: 16),
            IconLabel(label: study.activeSubjectCount.toString(), iconData: MdiIcons.run, color: Colors.green),
            SizedBox(width: 16),
            IconLabel(label: study.totalMissedDays.toString(), iconData: MdiIcons.calendarRemove, color: Colors.orange),
            VerticalDivider(),
            if (study.participation == Participation.open) openParticipationIcon() else inviteParticipationIcon(),
            SizedBox(width: 16),
            if (owner) ...[
              if (study.resultSharing == ResultSharing.public) publicResultsIcon() else privateResultsIcon(),
              SizedBox(width: 16),
            ],
            if (owner)
              if (study.published) publishedIcon() else draftIcon(),
          ],
        ),
        onTap: () => context.read<AppState>().openDetails(study.id));
  }
}
