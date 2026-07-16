import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/util/debug_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _inviteDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<AppState>();
    if (!_inviteDialogShown &&
        state.hasPendingDeepLink &&
        state.selectedStudy != null) {
      _inviteDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInviteDialog());
    }
  }

  Future<void> _showInviteDialog() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final studyTitle = state.selectedStudy?.title ?? '';
    final l10n = AppLocalizations.of(context)!;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.you_have_been_invited),
        content: Text(studyTitle),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.decline),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.accept),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (accepted == true) {
      await context.push('/${RouteNames.terms}');
      if (!mounted) return;
      setState(() => _inviteDialogShown = false);
    } else {
      await PendingDeepLinkService.clear(state);
      _inviteDialogShown = false;
    }
  }

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
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onDoubleTap: () => DebugScreen.showDebugScreen(context),
                    child: const Image(
                      image: AssetImage('assets/icon/logo.png'),
                      height: 140,
                    ),
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
                    onPressed: () => context.push('/${RouteNames.terms}'),
                    label: Text(l10n.browse_public_studies),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('welcome_use_invite_code'),
                    style: secondaryButtonStyle,
                    icon: const Icon(Icons.vpn_key_outlined),
                    onPressed: () =>
                        context.push('/${RouteNames.terms}?invite=true'),
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
                    onPressed: () =>
                        context.pushNamed(RouteNames.restoreAccount),
                    label: Text(l10n.restore_studyu_account),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      TextButton(
                        key: const ValueKey('welcome_about'),
                        onPressed: () => context.push('/${RouteNames.about}'),
                        child: Text(l10n.what_is_studyu),
                      ),
                      TextButton(
                        key: const ValueKey('welcome_faq'),
                        onPressed: () => context.push('/${RouteNames.faq}'),
                        child: Text(l10n.faq),
                      ),
                      TextButton(
                        key: const ValueKey('welcome_contact'),
                        onPressed: () => context.push('/${RouteNames.contact}'),
                        child: Text(l10n.contact),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      key: const ValueKey('welcome_debug_onboarding'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                      icon: const Icon(Icons.bug_report),
                      onPressed: () => context.go('/${RouteNames.onboarding}'),
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
