import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
import '../../widgets/bottom_onboarding_navigation.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = kDebugMode;
  bool _acceptedPrivacy = kDebugMode;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: (state.appConfig != null)
              ? legalSection(context, state.appConfig)
              : RetryFutureBuilder<AppConfig>(
                  tryFunction: AppConfig.getAppConfig,
                  successBuilder: (BuildContext context, AppConfig? appConfig) => legalSection(context, appConfig)),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: userCanContinue()
            ? () async {
                final success = await anonymousSignUp();
                if (success) {
                  if (!mounted) return;
                  Navigator.pushNamed(context, Routes.studySelection);
                }
              }
            : null,
      ),
    );
  }

  Widget legalSection(BuildContext context, AppConfig? appConfig) {
    final appLocale = Localizations.localeOf(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LegalSection(
              title: AppLocalizations.of(context)!.terms,
              description: AppLocalizations.of(context)!.terms_content,
              acknowledgment: AppLocalizations.of(context)!.terms_agree,
              onChange: (val) => setState(() => _acceptedTerms = val!),
              isChecked: _acceptedTerms,
              icon: Icon(MdiIcons.fileDocumentEdit),
              pdfUrl: appConfig!.appTerms[appLocale.languageCode.toString()],
              pdfUrlLabel: AppLocalizations.of(context)!.terms_read,
            ),
            const SizedBox(height: 20),
            LegalSection(
              title: AppLocalizations.of(context)!.privacy,
              description: AppLocalizations.of(context)!.privacy_content,
              acknowledgment: AppLocalizations.of(context)!.privacy_agree,
              onChange: (val) => setState(() => _acceptedPrivacy = val!),
              isChecked: _acceptedPrivacy,
              icon: Icon(MdiIcons.shieldLock),
              pdfUrl: appConfig.appPrivacy[appLocale.languageCode.toString()],
              pdfUrlLabel: AppLocalizations.of(context)!.privacy_read,
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              icon: Icon(MdiIcons.scaleBalance),
              onPressed: () async {
                final uri = Uri.parse(appConfig.imprint[appLocale.languageCode.toString()]!);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              label: Text(AppLocalizations.of(context)!.imprint_read),
            ),
          ],
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final String? title;
  final String? description;
  final Icon? icon;
  final String? pdfUrl;
  final String? pdfUrlLabel;
  final String? acknowledgment;
  final bool? isChecked;
  final ValueChanged<bool?>? onChange;

  const LegalSection({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.pdfUrl,
    this.pdfUrlLabel,
    this.acknowledgment,
    this.isChecked,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title!, style: theme.textTheme.headlineMedium!.copyWith(color: theme.primaryColor)),
        const SizedBox(height: 20),
        Text(description!),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: icon!,
          onPressed: () async {
            final uri = Uri.parse(pdfUrl!);
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          label: Text(pdfUrlLabel!),
        ),
        CheckboxListTile(title: Text(acknowledgment!), value: isChecked, onChanged: onChange),
      ],
    );
  }
}
