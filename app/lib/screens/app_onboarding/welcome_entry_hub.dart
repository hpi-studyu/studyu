import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class WelcomeEntryHub extends StatelessWidget {
  final VoidCallback onLogoDoubleTap;
  final VoidCallback onBrowsePublicStudies;
  final VoidCallback onUseInviteCode;
  final VoidCallback onRestoreAccount;
  final VoidCallback onAbout;
  final VoidCallback onFaq;
  final VoidCallback onContact;
  final VoidCallback? onDebugOnboarding;
  final String logoAssetPath;

  const WelcomeEntryHub({
    required this.onLogoDoubleTap,
    required this.onBrowsePublicStudies,
    required this.onUseInviteCode,
    required this.onRestoreAccount,
    required this.onAbout,
    required this.onFaq,
    required this.onContact,
    this.onDebugOnboarding,
    this.logoAssetPath = 'assets/icon/logo.png',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryButtonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: theme.textTheme.titleMedium,
    );
    final secondaryButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: theme.textTheme.titleMedium,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            key: const PageStorageKey('welcome_entry_hub_scroll'),
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onDoubleTap: onLogoDoubleTap,
                    child: Image.asset(logoAssetPath, height: 140),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.welcome_find_study_title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcome_find_study_description,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    key: const ValueKey('welcome_get_started'),
                    style: primaryButtonStyle,
                    icon: const Icon(Icons.search),
                    onPressed: onBrowsePublicStudies,
                    label: Text(l10n.browse_public_studies),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('welcome_use_invite_code'),
                    style: secondaryButtonStyle,
                    icon: const Icon(Icons.vpn_key_outlined),
                    onPressed: onUseInviteCode,
                    label: Text(l10n.invite_code_button),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    l10n.welcome_returning_participant,
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('welcome_restore_account'),
                    style: secondaryButtonStyle,
                    icon: const Icon(Icons.restore),
                    onPressed: onRestoreAccount,
                    label: Text(l10n.restore_studyu_account),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      TextButton(
                        key: const ValueKey('welcome_about'),
                        onPressed: onAbout,
                        child: Text(l10n.what_is_studyu),
                      ),
                      TextButton(
                        key: const ValueKey('welcome_faq'),
                        onPressed: onFaq,
                        child: Text(l10n.faq),
                      ),
                      TextButton(
                        key: const ValueKey('welcome_contact'),
                        onPressed: onContact,
                        child: Text(l10n.contact),
                      ),
                    ],
                  ),
                  if (onDebugOnboarding != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      key: const ValueKey('welcome_debug_onboarding'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                      icon: const Icon(Icons.bug_report),
                      onPressed: onDebugOnboarding,
                      label: const Text('Show onboarding'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
