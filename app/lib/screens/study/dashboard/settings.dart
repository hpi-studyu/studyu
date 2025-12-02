import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/utils/recovery_qr_utils.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  List<String> get _phrase {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final id = BigInt.parse(user.id.replaceAll('-', ''), radix: 16);
    return encode(id);
  }

  void _copyToClipboard() {
    final text = _phrase.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
      ),
    );
  }

  Future<void> _shareText() async {
    try {
      await RecoveryQrUtils.shareRecoveryText(_phrase);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _shareQr() async {
    try {
      await RecoveryQrUtils.shareRecoveryQr(_phrase);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _downloadText() async {
    try {
      await RecoveryQrUtils.downloadRecoveryText(_phrase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.file_saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.file_save_error),
          ),
        );
      }
    }
  }

  Future<void> _downloadQr() async {
    try {
      await RecoveryQrUtils.downloadRecoveryQr(_phrase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.file_saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.file_save_error),
          ),
        );
      }
    }
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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            getDropdownRow(context),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.key, color: Colors.blue),
                  title: Text(
                    AppLocalizations.of(context)!.recovery_phrase_header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.recovery_phrase_save_hint,
                    style: theme.textTheme.bodySmall,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: Colors.amber.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.recovery_security_warning,
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: _phrase
                                      .map((word) => Chip(label: Text(word)))
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: _copyToClipboard,
                                  tooltip: AppLocalizations.of(
                                    context,
                                  )!.copy_to_clipboard,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: RecoveryQrUtils.renderQrWidget(
                              RecoveryQrUtils.buildQrCode(
                                RecoveryQrUtils.generateDeepLink(_phrase),
                              ),
                              size: 200,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await showMenu(
                                      context: context,
                                      position: const RelativeRect.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          onTap: _shareText,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.share_as_text,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: _shareQr,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.share_as_qr,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: const Icon(Icons.share),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.share_recovery,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await showMenu(
                                      context: context,
                                      position: const RelativeRect.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          onTap: _downloadText,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.download_as_text,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: _downloadQr,
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.download_as_qr,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: const Icon(Icons.download),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.download_recovery,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${AppLocalizations.of(context)!.study_current} ${subject!.study.title}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(MdiIcons.exitToApp),
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
