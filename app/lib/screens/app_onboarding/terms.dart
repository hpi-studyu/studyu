import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/deep_link_error_helper.dart';
import 'package:studyu_app/services/deep_link_service.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
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

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = kDebugMode;
  bool _acceptedPrivacy = kDebugMode;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy;
  }

  Future<void> _handlePendingDeepLink(AppState state) async {
    final result = await DeepLinkService.processDeepLink(
      studyId: state.pendingDeepLinkStudyId,
      inviteCode: state.pendingDeepLinkInviteCode,
      isAuthenticated: true,
      activeStudyId: state.activeSubject?.studyId,
    );

    state.clearPendingDeepLink();
    if (!mounted) return;

    switch (result) {
      case DeepLinkSuccess(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
      ):
        state.selectedStudy = study;
        if (inviteCode != null) {
          state.inviteCode = inviteCode;
          state.preselectedInterventionIds = preselectedInterventionIds;
        }
        context.push('/${RouteNames.studyOverview}');
      case DeepLinkError(type: final errorType, :final errorValue):
        final message = getDeepLinkErrorMessage(
          AppLocalizations.of(context)!,
          errorType,
          errorValue,
        );
        final ok = AppLocalizations.of(context)!.ok;
        await PendingDeepLinkService.clear(state);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: ok, onPressed: () {}),
          ),
        );
        context.go('/${RouteNames.welcome}');
      case DeepLinkNeedsAuth():
        await PendingDeepLinkService.clear(state);
        if (!mounted) return;
        context.go('/${RouteNames.welcome}');
    }
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
              if (success) {
                if (!mounted) return;
                final state = context.read<AppState>();
                if (state.hasPendingDeepLink) {
                  await _handlePendingDeepLink(state);
                } else {
                  context.push('/${RouteNames.studySelection}');
                }
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
