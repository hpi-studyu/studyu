import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/services/speech/speech_to_text_language.dart';
import 'package:studyu_app/services/speech/speech_to_text_preferences.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale? _selectedValue;
  bool? _analyticsValue;
  StudySubject? subject;
  bool _speechPrefsRequested = false;
  bool _speechPrefsLoading = true;
  SpeechRecognitionLanguage _speechLanguage = SpeechRecognitionLanguage.english;

  @override
  void initState() {
    super.initState();
    _analyticsValue = AppAnalytics.isUserEnabled;
    _selectedValue = context.read<AppLanguage>().appLocal;
    subject = context.read<AppState>().activeSubject;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_speechPrefsRequested) {
      _speechPrefsRequested = true;
      _loadSpeechPreferences();
    }
  }

  Future<void> _loadSpeechPreferences() async {
    final fallbackLocale = Localizations.maybeLocaleOf(context);
    final language = await SpeechToTextPreferences.preferredLanguage(
      fallbackLocale: fallbackLocale,
    );
    if (!mounted) return;
    setState(() {
      _speechLanguage = language;
      _speechPrefsLoading = false;
    });
  }

  Future<void> _changeSpeechLanguage(SpeechRecognitionLanguage language) async {
    setState(() {
      _speechLanguage = language;
    });
    await SpeechToTextPreferences.setPreferredLanguage(language);
  }

  Widget getDropdownRow(BuildContext context) {
    final dropDownItems = <DropdownMenuItem<Locale>>[];

    for (final locale in AppLocalizations.supportedLocales) {
      dropDownItems.add(
        DropdownMenuItem(
          value: locale,
          child: Text(localeName(context, locale.languageCode)!),
        ),
      );
    }

    dropDownItems.add(const DropdownMenuItem(child: Text('System')));

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${AppLocalizations.of(context)!.language}:'),
            const SizedBox(width: 5),
            DropdownButton<Locale>(
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
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${AppLocalizations.of(context)!.allow_analytics}: '),
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(milliseconds: 10000),
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              message: AppLocalizations.of(context)!.allow_analytics_desc,
              child: const Icon(Icons.info),
            ),
            const SizedBox(width: 5),
            Switch(
              value: _analyticsValue!,
              onChanged: (value) {
                setState(() {
                  _analyticsValue = value;
                });
                AppAnalytics.setEnabled(value);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getDropdownRow(context),
            const SizedBox(height: 24),
            _buildSpeechSection(theme, loc),
            const SizedBox(height: 32),
            _buildStudySection(theme, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechSection(ThemeData theme, AppLocalizations loc) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.speech_to_text_title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              loc.speech_to_text_description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (_speechPrefsLoading)
              const LinearProgressIndicator()
            else ...[
              DropdownMenu<SpeechRecognitionLanguage>(
                initialSelection: _speechLanguage,
                label: Text(loc.speech_to_text_language_label),
                onSelected: (lang) {
                  if (lang != null) _changeSpeechLanguage(lang);
                },
                dropdownMenuEntries: SpeechRecognitionLanguage.values
                    .map(
                      (lang) => DropdownMenuEntry(
                        value: lang,
                        label: _languageLabel(lang, loc),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudySection(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        Text(
          '${loc.study_current} ${subject!.study.title}',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(MdiIcons.exitToApp),
          label: Text(loc.opt_out),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => OptOutAlertDialog(subject: subject),
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: Text(loc.delete_data),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => DeleteAlertDialog(subject: subject),
            );
          },
        ),
      ],
    );
  }

  String _languageLabel(
    SpeechRecognitionLanguage language,
    AppLocalizations loc,
  ) {
    switch (language) {
      case SpeechRecognitionLanguage.german:
        return loc.speech_to_text_language_german;
      case SpeechRecognitionLanguage.english:
        return loc.speech_to_text_language_english;
    }
  }
}

class OptOutAlertDialog extends StatelessWidget {
  final StudySubject? subject;

  const OptOutAlertDialog({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('${AppLocalizations.of(context)!.opt_out}?'),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(text: AppLocalizations.of(context)!.soft_delete_desc),
            TextSpan(
              text: subject!.study.title,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextSpan(text: AppLocalizations.of(context)!.soft_delete_desc_2),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          icon: Icon(MdiIcons.exitToApp),
          label: Text(AppLocalizations.of(context)!.opt_out),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
          onPressed: () async {
            await subject!.softDelete();
            await deleteActiveStudyReference();
            await FitbitHandler.deleteFitbitCredentials(subject!.studyId);
            if (context.mounted) await cancelNotifications(context);
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.studySelection,
                (_) => false,
              );
            }
          },
        ),
      ],
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final StudySubject? subject;

  const DeleteAlertDialog({super.key, required this.subject});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${AppLocalizations.of(context)!.delete_data}?'),
    content: Text(AppLocalizations.of(context)!.hard_delete_desc),
    actions: [
      ElevatedButton.icon(
        icon: const Icon(Icons.delete),
        label: Text(AppLocalizations.of(context)!.delete_data),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          try {
            await subject!.delete(); // hard-delete the subject
            await deleteLocalData();
            await FitbitHandler.deleteFitbitCredentials(subject!.studyId);
            if (context.mounted) await cancelNotifications(context);
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.welcome,
                (_) => false,
              );
            }
          } on SocketException catch (_) {}
        },
      ),
    ],
  );
}
