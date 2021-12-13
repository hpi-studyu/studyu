import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

Future<Study> publishStudy(BuildContext context, Study study) async {
  final publishingAccepted =
      await showDialog<bool>(context: context, builder: (_) => PublishAlertDialog(studyTitle: study.title));
  if (publishingAccepted) {
    study.published = true;
    final savedStudy = await study.save();
    if (savedStudy != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).was_saved_and_published}')),
      );
      return savedStudy;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).failed_saving}')));
    }
  }
  return null;
}

Future<Study> saveDraft(BuildContext context, Study study) async {
  final savedStudy = study.save();
  if (savedStudy != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).was_saved_as_draft}')));
    return savedStudy;
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).failed_saving}')));
    return null;
  }
}

class PublishAlertDialog extends StatelessWidget {
  final String studyTitle;

  const PublishAlertDialog({@required this.studyTitle}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(AppLocalizations.of(context).lock_and_publish),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            const TextSpan(text: 'The study '),
            TextSpan(
              text: studyTitle,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextSpan(text: AppLocalizations.of(context).really_want_to_publish),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.publish),
          style: ElevatedButton.styleFrom(primary: Colors.green, elevation: 0),
          label: Text('${AppLocalizations.of(context).publish} $studyTitle'),
        )
      ],
    );
  }
}
