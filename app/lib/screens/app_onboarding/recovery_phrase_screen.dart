import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool _isChecked = kDebugMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPage(
        title: AppLocalizations.of(context)!.recovery_phrase_header,
        description: AppLocalizations.of(context)!.recovery_phrase_save_hint,
        bottomCheckboxItems: _confirmationItems(),
        bottomNavigationBar: _buildNavigation(),
        child: const RecoveryPhraseContent(),
      ),
    );
  }

  List<OnboardingCheckboxItem> _confirmationItems() {
    return [
      OnboardingCheckboxItem(
        label: AppLocalizations.of(context)!.recovery_phrase_saved_confirmation,
        value: _isChecked,
        onChanged: (value) {
          setState(() {
            _isChecked = value ?? false;
          });
        },
      ),
    ];
  }

  Widget _buildNavigation() {
    return BottomOnboardingNavigation(
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(RouteNames.terms);
        }
      },
      onNext: _isChecked
          ? () {
              context.pushNamed(RouteNames.studySelection);
            }
          : null,
    );
  }
}
