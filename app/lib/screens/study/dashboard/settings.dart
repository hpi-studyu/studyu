import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/error_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import '../../../models/app_error.dart';

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

    dropDownItems.add(
      const DropdownMenuItem(
        child: Text('System'),
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${AppLocalizations.of(context)!.language}:'),
            const SizedBox(
              width: 5,
            ),
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
              child: const Icon(
                Icons.info,
              ),
            ),
            const SizedBox(
              width: 5,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            getDropdownRow(context),
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
            try {
              await subject!.softDelete();
              await deleteActiveStudyReference();
              if (context.mounted) await cancelNotifications(context);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.studySelection,
                  (_) => false,
                );
              }
            } on SocketException catch (_) {
              ErrorHandler.showSnackbar(context, "Connection error");
            } on AppError catch (e) {
              ErrorHandler.showSnackbar(context, e.message);
            } catch (e) {
              StudyULogger.error(e.toString());
              ErrorHandler.showSnackbar(
                context,
                "An error occured while opting out. Please try again later",
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
        content: Text(
          AppLocalizations.of(context)!.hard_delete_desc,
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(AppLocalizations.of(context)!.delete_data),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await subject!.delete(); // hard-delete
                await deleteLocalData();
                if (context.mounted) await cancelNotifications(context);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.welcome,
                    (_) => false,
                  );
                }
              } on SocketException catch (_) {
                ErrorHandler.showSnackbar(context, "Connection error");
              } on AppError catch (e) {
                ErrorHandler.showSnackbar(context, e.message);
              } catch (e) {
                StudyULogger.error(e.toString());

                ErrorHandler.showSnackbar(
                  context,
                  "An error occured while deleting data. Please try again later",
                );
              }
            },
          ),
        ],
      );
}
