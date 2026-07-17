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
  final String logoAssetPath;

  const WelcomeEntryHub({
    required this.onLogoDoubleTap,
    required this.onBrowsePublicStudies,
    required this.onUseInviteCode,
    required this.onRestoreAccount,
    required this.onAbout,
    required this.onFaq,
    required this.onContact,
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
    final footerLinkStyle = TextButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            key: const PageStorageKey('welcome_entry_hub_scroll'),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  minHeight: constraints.maxHeight > 40
                      ? constraints.maxHeight - 40
                      : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   l10n.welcome_find_study_description,
                        //   style: theme.textTheme.bodyLarge,
                        //   textAlign: TextAlign.center,
                        // ),
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
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                              key: const ValueKey('welcome_about'),
                              style: footerLinkStyle,
                              onPressed: onAbout,
                              child: Text(l10n.what_is_studyu),
                            ),
                            Text('·', style: theme.textTheme.bodyMedium),
                            TextButton(
                              key: const ValueKey('welcome_faq'),
                              style: footerLinkStyle,
                              onPressed: onFaq,
                              child: Text(l10n.faq),
                            ),
                            Text('·', style: theme.textTheme.bodyMedium),
                            TextButton(
                              key: const ValueKey('welcome_contact'),
                              style: footerLinkStyle,
                              onPressed: onContact,
                              child: Text(l10n.contact),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 8),
                      child: Text(
                        l10n.made_with_love_in_potsdam,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
