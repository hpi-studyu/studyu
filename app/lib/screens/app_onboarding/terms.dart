import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:studyou_core/queries/queries.dart';

import '../../routes.dart';
import '../../util/download.dart';
import '../../util/localization.dart';
import '../../widgets/bottom_onboarding_navigation.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = true;
  bool _acceptedPrivacy = true;
  bool _acceptedDisclaimer = true;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy && _acceptedDisclaimer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final translations = Map.fromEntries([
      'terms',
      'terms_content',
      'terms_agree',
      'privacy',
      'privacy_content',
      'privacy_agree',
      'disclaimer',
      'disclaimer_content',
      'disclaimer_agree'
    ].map((key) => MapEntry(key, Nof1Localizations.of(context).translate(key))));

    final pdfContent = <pw.Widget>[
      pw.Header(
        level: 0,
        child: pw.Text(translations['terms'], textScaleFactor: 2),
      ),
      pw.Paragraph(text: translations['terms_description']),
      pw.Header(
        level: 0,
        child: pw.Text(translations['privacy'], textScaleFactor: 2),
      ),
      pw.Paragraph(text: translations['privacy_description']),
      pw.Header(
        level: 0,
        child: pw.Text(translations['disclaimer'], textScaleFactor: 2),
      ),
      pw.Paragraph(text: translations['disclaimer_description']),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...buildSection(theme,
                      title: translations['terms'],
                      descriptionText: translations['terms_content'],
                      acknowledgmentText: translations['terms_agree'],
                      onChange: (val) => setState(() => _acceptedTerms = val),
                      isChecked: _acceptedTerms),
                  ...buildSection(theme,
                      title: translations['privacy'],
                      descriptionText: translations['privacy_content'],
                      acknowledgmentText: translations['privacy_agree'],
                      onChange: (val) => setState(() => _acceptedPrivacy = val),
                      isChecked: _acceptedPrivacy),
                  ...buildSection(theme,
                      title: translations['disclaimer'],
                      descriptionText: translations['disclaimer_content'],
                      acknowledgmentText: translations['disclaimer_agree'],
                      onChange: (val) => setState(() => _acceptedDisclaimer = val),
                      isChecked: _acceptedDisclaimer),
                  SizedBox(
                    height: 20,
                  ),
                  FlatButton.icon(
                    onPressed: () => pdfDownload(context, 'StudyU_Terms_of_Service', pdfContent),
                    label: Text('Download'),
                    icon: Icon(MdiIcons.download),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: userCanContinue()
            ? () {
                UserQueries.getOrCreateUser();
                Navigator.pushNamed(context, Routes.studySelection);
              }
            : null,
      ),
    );
  }

  List<Widget> buildSection(ThemeData theme,
      {String title, String descriptionText, String acknowledgmentText, Function onChange, bool isChecked}) {
    return <Widget>[
      Text(title, style: theme.textTheme.headline3),
      Text(descriptionText),
      CheckboxListTile(title: Text(acknowledgmentText), value: isChecked, onChanged: onChange),
      SizedBox(height: 40),
    ];
  }
}
