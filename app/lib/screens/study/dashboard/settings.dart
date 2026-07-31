import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/restore_account_service.dart';
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
  StudySubject? subject;

  @override
  void initState() {
    super.initState();
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

    dropDownItems.add(
      DropdownMenuItem(
        child: Text(AppLocalizations.of(context)!.use_device_language),
      ),
    );
    return dropDownItems;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go('/${RouteNames.dashboard}'),
        ),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // General section header
              Text(
                AppLocalizations.of(context)!.general_section,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Language card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: theme.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.language,
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                      ),
                      DropdownButton<Locale>(
                        value: _selectedValue,
                        style: theme.textTheme.bodyMedium,
                        hint: Text(
                          AppLocalizations.of(context)!.use_device_language,
                        ),
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
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.study_settings_section,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Dashboard showcase reset
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: theme.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.dashboard_tour,
                          style: theme.textTheme.bodyMedium!.copyWith(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        key: const ValueKey(
                          'settings_show_dashboard_showcase_again',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        onPressed: () async {
                          await DashboardShowcaseStorage.reset();
                          if (!context.mounted) return;
                          context.pop(true);
                        },
                        child: Text(AppLocalizations.of(context)!.show_again),
                      ),
                    ],
                  ),
                ),
              ),
              if (context.watch<AppState>().showParticipantRecovery) ...[
                const SizedBox(height: 8),
                const RecoveryPhraseWidget(),
              ],
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, color: theme.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.study_information,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      OutlinedButton(
                        key: const ValueKey('settings_study_information'),
                        onPressed: () =>
                            context.push('/${RouteNames.studyInformation}'),
                        child: Text(
                          AppLocalizations.of(context)!.view_study_information,
                        ),
                      ),
                    ],
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
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.leave_study_description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.delete_study_data_description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
          style: theme.textTheme.bodyMedium,
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
    final l10n = AppLocalizations.of(context)!;
    var acknowledged = false;

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.leave_study_keep_data_title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.leave_study_keep_data_body(
                  subject!.study.title ?? l10n.not_available,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  l10n.acknowledge_consequences,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: acknowledged,
                onChanged: (value) {
                  setDialogState(() => acknowledged = value ?? false);
                },
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: context.pop,
            child: Text(l10n.stay_in_study),
          ),
          ElevatedButton.icon(
            icon: const Icon(MdiIcons.exitToApp),
            label: Text(l10n.leave_keep_data),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: acknowledged
                ? () async {
                    try {
                      await subject!.softDelete();
                    } on SocketException catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.no_internet_connection,
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    await deleteActiveStudyReference();
                    await FitbitHandler.deleteFitbitCredentials(
                      subject!.studyId,
                    );
                    if (context.mounted) await cancelNotifications(context);
                    if (context.mounted) {
                      context.go('/${RouteNames.studySelection}');
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final StudySubject? subject;

  const DeleteAlertDialog({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var acknowledged = false;

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.leave_study_delete_data_title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.leave_study_delete_data_body(
                  subject!.study.title ?? l10n.not_available,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  l10n.acknowledge_consequences,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: acknowledged,
                onChanged: (value) {
                  setDialogState(() => acknowledged = value ?? false);
                },
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: context.pop,
            child: Text(l10n.stay_in_study),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(l10n.leave_delete_data),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: acknowledged
                ? () async {
                    try {
                      await subject!.delete();
                    } on SocketException catch (_) {
                      // Device is offline — preserve local data so nothing is lost
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.no_internet_connection,
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
                    await FitbitHandler.deleteFitbitCredentials(
                      subject!.studyId,
                    );
                    if (context.mounted) await cancelNotifications(context);
                    if (context.mounted) {
                      context.go('/${RouteNames.welcome}');
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
