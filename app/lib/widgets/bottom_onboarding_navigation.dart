import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? backLabel;
  final String? nextLabel;
  final bool hideNext;
  final bool hideBack;
  final bool backEnabled;
  final Icon? nextIcon;
  final Icon? backIcon;
  final Widget? progress;

  const BottomOnboardingNavigation({
    super.key,
    this.onNext,
    this.onBack,
    this.backLabel,
    this.nextLabel,
    this.hideNext = false,
    this.hideBack = false,
    this.backEnabled = true,
    this.nextIcon,
    this.backIcon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    void handleBack() {
      if (onBack != null) {
        onBack!.call();
        return;
      }

      final appState = context.read<AppState>();
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (appState.isPreview) {
        final previousRoute = switch (currentRoute) {
          Routes.dashboard => Routes.journey,
          Routes.journey => Routes.consent,
          Routes.consent => Routes.studyOverview,
          Routes.interventionSelection => Routes.studyOverview,
          _ => null,
        };
        if (previousRoute != null) {
          Navigator.pushReplacementNamed(context, previousRoute);
          return;
        }
      }

      Navigator.pop(context);
    }

    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Visibility(
              visible: !hideBack,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                onPressed: backEnabled ? handleBack : null,
                child: Row(
                  children: [
                    backIcon ?? const Icon(Icons.navigate_before),
                    Text(backLabel ?? AppLocalizations.of(context)!.back),
                  ],
                ),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(width: 8),
              Expanded(child: progress!),
              const SizedBox(width: 8),
            ] else
              const Spacer(),
            Visibility(
              visible: !hideNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                onPressed: onNext,
                child: Row(
                  children: [
                    Text(nextLabel ?? AppLocalizations.of(context)!.next),
                    nextIcon ?? const Icon(Icons.navigate_next),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
