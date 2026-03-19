import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? backLabel;
  final String? nextLabel;
  final bool hideNext;
  final bool hideBack;
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
    this.nextIcon,
    this.backIcon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Visibility(
              visible: !hideBack && (onBack != null || context.canPop()),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                onPressed:
                    onBack ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
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
