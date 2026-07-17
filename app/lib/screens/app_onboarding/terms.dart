import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

@visibleForTesting
String? routeAfterTerms(AppState state, {required bool canPop}) {
  if (state.selectedStudy == null) return '/${RouteNames.studySelection}';
  return canPop ? null : '/${RouteNames.studyOverview}';
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = kDebugMode;
  bool _acceptedPrivacy = kDebugMode;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPage(
        title: AppLocalizations.of(context)!.legal_documents,
        description: AppLocalizations.of(context)!.legal_documents_description,
        bottomNavigationBar: _buildNavigation(),
        child: RetryFutureBuilder<AppConfig>(
          tryFunction: AppConfig.getAppConfig,
          successBuilder: (BuildContext context, AppConfig? appConfig) =>
              legalSection(context, appConfig),
        ),
      ),
    );
  }

  Widget legalSection(BuildContext context, AppConfig? appConfig) {
    final appLocale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LegalSection(
          title: AppLocalizations.of(context)!.terms,
          description: AppLocalizations.of(context)!.terms_content,
          icon: const Icon(MdiIcons.fileDocumentEdit),
          pdfUrl: appConfig!.appTerms[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.terms_read,
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context)!.terms_agree),
          value: _acceptedTerms,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 20),
        LegalSection(
          title: AppLocalizations.of(context)!.privacy,
          description: AppLocalizations.of(context)!.privacy_content,
          icon: const Icon(MdiIcons.shieldLock),
          pdfUrl: appConfig.appPrivacy[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.privacy_read,
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context)!.privacy_agree),
          value: _acceptedPrivacy,
          onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 20),
        LegalSection(
          title: AppLocalizations.of(context)!.legal_notice,
          description: AppLocalizations.of(context)!.legal_notice_content,
          icon: const Icon(MdiIcons.scaleBalance),
          pdfUrl: appConfig.imprint[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.imprint_read,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNavigation() {
    return BottomOnboardingNavigation(
      backButtonKey: const ValueKey('terms_back'),
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/${RouteNames.welcome}');
        }
      },
      nextButtonKey: const ValueKey('terms_continue'),
      onNext: userCanContinue()
          ? () async {
              final success = await ensureParticipantSignedIn();
              if (!success || !mounted) return;
              final route = routeAfterTerms(
                context.read<AppState>(),
                canPop: context.canPop(),
              );
              if (route == null) {
                context.pop(true);
              } else {
                context.go(route);
              }
            }
          : null,
    );
  }
}

class LegalSection extends StatelessWidget {
  final String? title;
  final String? description;
  final Icon? icon;
  final String? pdfUrl;
  final String? pdfUrlLabel;

  const LegalSection({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.pdfUrl,
    this.pdfUrlLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          title!,
          style: theme.textTheme.titleLarge!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(description!),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: icon,
          onPressed: () async {
            final uri = Uri.parse(pdfUrl!);
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          label: Text(pdfUrlLabel!),
        ),
      ],
    );
  }
}
