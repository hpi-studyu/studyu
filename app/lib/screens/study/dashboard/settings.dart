import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Locale _selectedValue;
  StudySubject subject;

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
          child: Text(localeName(context, locale.languageCode)),
        ),
      );
    }

    dropDownItems.add(
      const DropdownMenuItem(
        child: Text('System'),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('${AppLocalizations.of(context).language}:'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            getDropdownRow(context),
            const SizedBox(height: 24),
            Text(
              '${AppLocalizations.of(context).study_current} ${subject.study.title}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(MdiIcons.exitToApp),
              label: Text(AppLocalizations.of(context).opt_out),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
              onPressed: () {
                showDialog(context: context, builder: (_) => OptOutAlertDialog(subject: subject));
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: Text(AppLocalizations.of(context).delete_data),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                showDialog(context: context, builder: (_) => DeleteAlertDialog());
              },
            )
          ],
        ),
      ),
    );
  }
}

class OptOutAlertDialog extends StatelessWidget {
  final StudySubject subject;

  const OptOutAlertDialog({@required this.subject}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Opt-out of study?'),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            const TextSpan(text: 'The progress of your current study '),
            TextSpan(
              text: subject.study.title,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const TextSpan(
              text: ' will be deleted and cannot be recovered. Previously completed studies will not be deleted.',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          icon: const Icon(MdiIcons.exitToApp),
          label: const Text('Opt-out'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], elevation: 0),
          onPressed: () async {
            subject.delete();
            deleteActiveStudyReference();
            Navigator.pushNamedAndRemoveUntil(context, Routes.studySelection, (_) => false);
          },
        )
      ],
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Delete all local data?'),
        content: const Text(
          'You will not be able to restore your data. Your anonymized data may still be used for research purposes.',
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete all local data'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              deleteLocalData();
              Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (_) => false);
            },
          )
        ],
      );
}
