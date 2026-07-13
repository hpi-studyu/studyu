import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart' show PostgrestException;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale? _selectedValue;
  StudySubject? subject;

  @override
  void initState() {
    super.initState();
    _selectedValue = context.read<AppLanguage>().appLocal;
    subject = context.read<AppState>().activeSubject;
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              getDropdownRow(context),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('settings_show_dashboard_showcase_again'),
                icon: const Icon(Icons.help_outline),
                label: Text(
                  AppLocalizations.of(context)!.show_dashboard_showcase_again,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: () async {
                  await DashboardShowcaseStorage.reset();
                  if (!context.mounted) return;
                  context.pop(true);
                },
              ),
              const SizedBox(height: 24),
              Text(
                '${AppLocalizations.of(context)!.study_current} ${subject!.study.title}',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const ValueKey('settings_opt_out'),
                icon: const Icon(MdiIcons.exitToApp),
                label: Text(AppLocalizations.of(context)!.opt_out),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => OptOutAlertDialog(subject: subject),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const ValueKey('settings_delete_data'),
                icon: const Icon(Icons.delete),
                label: Text(AppLocalizations.of(context)!.delete_data),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteAlertDialog(subject: subject),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
          icon: const Icon(MdiIcons.exitToApp),
          label: Text(AppLocalizations.of(context)!.opt_out),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
          onPressed: () async {
            try {
              await subject!.softDelete();
            } on SocketException catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.no_internet_connection,
                    ),
                  ),
                );
              }
              return;
            }
            await deleteActiveStudyReference();
            await FitbitHandler.deleteFitbitCredentials(subject!.studyId);
            if (context.mounted) await cancelNotifications(context);
            if (context.mounted) {
              context.go('/${RouteNames.studySelection}');
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
            await subject!.delete();
          } on SocketException catch (_) {
            // Device is offline — preserve local data so nothing is lost
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.no_internet_connection,
                  ),
                ),
              );
            }
            return;
          } on PostgrestException catch (e) {
            if (e.code != 'PGRST116') {
              // Unexpected DB error — don't clear local data
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.error_occurred_with_message(e.message),
                    ),
                  ),
                );
              }
              return;
            }
            // PGRST116: subject already deleted from DB — proceed with local cleanup
          }
          // Reached when delete succeeded or subject was already gone from DB
          await deleteLocalData();
          await FitbitHandler.deleteFitbitCredentials(subject!.studyId);
          if (context.mounted) await cancelNotifications(context);
          if (context.mounted) {
            context.go('/${RouteNames.welcome}');
          }
        },
      ),
    ],
  );
}
