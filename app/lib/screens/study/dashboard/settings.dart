import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';
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
  bool? _analyticsValue;
  StudySubject? subject;

  @override
  void initState() {
    super.initState();
    _analyticsValue = AppAnalytics.isUserEnabled;
    _selectedValue = context.read<AppLanguage>().appLocal;
    subject = context.read<AppState>().activeSubject;
  }

  List<DropdownMenuItem<Locale>> _buildDropdownItems(BuildContext context) {
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
    return dropDownItems;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // General section header
              Text(
                AppLocalizations.of(context)!.general_section,
                style: theme.textTheme.titleMedium!.copyWith(),
              ),
              const SizedBox(height: 12),

              // Language card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.language,
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                      ),
                      DropdownButton<Locale>(
                        value: _selectedValue,
                        underline: const SizedBox(),
                        items: _buildDropdownItems(context),
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value;
                          });
                          context.read<AppLanguage>().changeLanguage(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Analytics card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.allow_analytics,
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                      ),
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
                ),
              ),

              // Dashboard showcase reset
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.show_dashboard_showcase_again,
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const ValueKey(
                          'settings_show_dashboard_showcase_again',
                        ),
                        icon: const Icon(Icons.help_outline),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.show_dashboard_showcase_again,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Recovery phrase card
              const RecoveryPhraseWidget(),

              const SizedBox(height: 24),

              // Current study section header
              Text(
                AppLocalizations.of(context)!.current_study_section,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.primaryColor,
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      textAlign: TextAlign.center,
                      subject!.study.title ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              //wrap buttons to fill the width for mobile phones but for web fixed width
              Text(
                textAlign: TextAlign.start,
                AppLocalizations.of(context)!.participation_options_section,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.primaryColor,
                ),
              ),
              Align(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width < 600
                        ? double.infinity
                        : 400,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      // Leave study button
                      FilledButton.icon(
                        icon: const Icon(MdiIcons.exitToApp),
                        label: Text(AppLocalizations.of(context)!.opt_out),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.red[700]!),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => OptOutAlertDialog(subject: subject),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Leave and delete button
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.delete),
                        label: Text(AppLocalizations.of(context)!.delete_data),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.pink[50],
                          foregroundColor: Colors.red[900],
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class RecoveryPhraseWidget extends StatefulWidget {
  const RecoveryPhraseWidget({super.key});

  @override
  State<RecoveryPhraseWidget> createState() => _RecoveryPhraseWidgetState();
}

class _RecoveryPhraseWidgetState extends State<RecoveryPhraseWidget> {
  bool _hasExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.lock_outline, color: theme.primaryColor),
        title: Text(
          AppLocalizations.of(context)!.recovery_phrase_header,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        onExpansionChanged: (expanded) {
          if (expanded && !_hasExpanded) {
            setState(() => _hasExpanded = true);
          }
        },
        children: [
          if (_hasExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.colorScheme.surface),
                child: const RecoveryPhraseContent(
                  useGridLayout: false,
                  showConfirmation: false,
                  showSaveHint: true,
                ),
              ),
            ),
        ],
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
          RestoreAccountService.clearCache();
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
