import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              GestureDetector(
                onDoubleTap: () {
                  DebugScreen.showDebugScreen(context);
                },
                child: const Image(
                  image: AssetImage('assets/icon/logo.png'),
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                key: const ValueKey('welcome_about'),
                icon: const Icon(Icons.info),
                onPressed: () => context.push('/${RouteNames.about}'),
                label: Text(
                  AppLocalizations.of(context)!.what_is_studyu,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                key: const ValueKey('welcome_contact'),
                icon: const Icon(MdiIcons.accountBox),
                onPressed: () => context.push('/${RouteNames.contact}'),
                label: Text(
                  AppLocalizations.of(context)!.contact,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                key: const ValueKey('welcome_faq'),
                icon: const Icon(MdiIcons.frequentlyAskedQuestions),
                onPressed: () => context.push('/${RouteNames.faq}'),
                label: Text(
                  AppLocalizations.of(context)!.faq,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                key: const ValueKey('welcome_get_started'),
                icon: const Icon(MdiIcons.rocket, size: 30),
                onPressed: () => context.push('/${RouteNames.terms}'),
                label: Text(
                  AppLocalizations.of(context)!.get_started,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.pushNamed(RouteNames.restoreAccount),
                child: Text(
                  AppLocalizations.of(context)!.restore_account,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
