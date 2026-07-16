import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/welcome_entry_hub.dart';
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
  Widget build(BuildContext context) => WelcomeEntryHub(
    onLogoDoubleTap: () => DebugScreen.showDebugScreen(context),
    onBrowsePublicStudies: () => context.push('/${RouteNames.terms}'),
    onUseInviteCode: () => context.push('/${RouteNames.terms}?invite=true'),
    onRestoreAccount: () => context.pushNamed(RouteNames.restoreAccount),
    onAbout: () => context.push('/${RouteNames.about}'),
    onFaq: () => context.push('/${RouteNames.faq}'),
    onContact: () => context.push('/${RouteNames.contact}'),
    onDebugOnboarding: kDebugMode
        ? () => context.go('/${RouteNames.onboarding}')
        : null,
  );
}
