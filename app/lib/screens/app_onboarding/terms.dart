import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../routes.dart';
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

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...buildSection(theme,
                    title: Nof1Localizations.of(context).translate('terms'),
                    descriptionText: Nof1Localizations.of(context).translate('terms_content'),
                    acknowledgmentText: Nof1Localizations.of(context).translate('terms_agree'),
                    onChange: (val) => setState(() => _acceptedTerms = val),
                    isChecked: _acceptedTerms),
                ...buildSection(theme,
                    title: Nof1Localizations.of(context).translate('privacy'),
                    descriptionText: Nof1Localizations.of(context).translate('privacy_content'),
                    acknowledgmentText: Nof1Localizations.of(context).translate('privacy_agree'),
                    onChange: (val) => setState(() => _acceptedPrivacy = val),
                    isChecked: _acceptedPrivacy),
                ...buildSection(theme,
                    title: Nof1Localizations.of(context).translate('disclaimer'),
                    descriptionText: Nof1Localizations.of(context).translate('disclaimer_content'),
                    acknowledgmentText: Nof1Localizations.of(context).translate('disclaimer_agree'),
                    onChange: (val) => setState(() => _acceptedDisclaimer = val),
                    isChecked: _acceptedDisclaimer),
              ],
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
