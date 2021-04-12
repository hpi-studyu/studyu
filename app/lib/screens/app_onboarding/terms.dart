import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu/util/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
import '../../widgets/bottom_onboarding_navigation.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = kDebugMode;
  bool _acceptedPrivacy = kDebugMode;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RetryFutureBuilder<AppConfig>(
            tryFunction: AppConfig().getAppConfig,
            successBuilder: (context, appConfig) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LegalSection(
                      title: AppLocalizations.of(context).terms,
                      description: AppLocalizations.of(context).terms_content,
                      acknowledgment: AppLocalizations.of(context).terms_agree,
                      onChange: (val) => setState(() => _acceptedTerms = val),
                      isChecked: _acceptedTerms,
                      icon: Icon(MdiIcons.fileDocumentEdit),
                      pdfUrl: appConfig.app_terms[appLocale.toString()],
                      pdfUrlLabel: AppLocalizations.of(context).terms_read,
                    ),
                    SizedBox(height: 20),
                    LegalSection(
                      title: AppLocalizations.of(context).privacy,
                      description: AppLocalizations.of(context).privacy_content,
                      acknowledgment: AppLocalizations.of(context).privacy_agree,
                      onChange: (val) => setState(() => _acceptedPrivacy = val),
                      isChecked: _acceptedPrivacy,
                      icon: Icon(MdiIcons.shieldLock),
                      pdfUrl: appConfig.app_privacy[appLocale.toString()],
                      pdfUrlLabel: AppLocalizations.of(context).privacy_read,
                    ),
                    SizedBox(height: 30),
                    OutlinedButton.icon(
                      icon: Icon(MdiIcons.scaleBalance),
                      onPressed: () => launch(appConfig.imprint[appLocale.toString()]),
                      label: Text(AppLocalizations.of(context).imprint_read),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: userCanContinue()
            ? () {
                UserQueries.generateUserId();
                Navigator.pushNamed(context, Routes.studySelection);
              }
            : null,
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final String title;
  final String description;
  final Icon icon;
  final String pdfUrl;
  final String pdfUrlLabel;
  final String acknowledgment;
  final bool isChecked;
  final ValueChanged<bool> onChange;

  const LegalSection(
      {Key key,
      this.title,
      this.description,
      this.icon,
      this.pdfUrl,
      this.pdfUrlLabel,
      this.acknowledgment,
      this.isChecked,
      this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title, style: theme.textTheme.headline4.copyWith(color: theme.primaryColor)),
        SizedBox(height: 20),
        Text(description),
        SizedBox(height: 20),
        OutlinedButton.icon(
          icon: icon,
          onPressed: () => launch(pdfUrl),
          label: Text(pdfUrlLabel),
        ),
        CheckboxListTile(title: Text(acknowledgment), value: isChecked, onChanged: onChange),
      ],
    );
  }
}
