import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/util/debug_screen.dart';
import 'package:studyu_app/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    DebugScreen.showDebugScreen(context);
                  },
                  child: const Image(
                    image: AssetImage('assets/icon/logo.png'),
                    height: 70,
                  ),
                ),
                const SizedBox(height: 20),
                WelcomeButton(
                  icon: Icons.info,
                  label: AppLocalizations.of(context)!.what_is_studyu,
                  onPressed: () => Navigator.pushNamed(context, Routes.about),
                ),
                const SizedBox(height: 20),
                WelcomeButton(
                  icon: Icons.person,
                  label: AppLocalizations.of(context)!.contact,
                  onPressed: () => Navigator.pushNamed(context, Routes.contact),
                ),
                const SizedBox(height: 20),
                WelcomeButton(
                  icon: Icons.quiz,
                  label: AppLocalizations.of(context)!.faq,
                  onPressed: () => Navigator.pushNamed(context, Routes.faq),
                ),
                const SizedBox(height: 20),
                WelcomeButton(
                  icon: Icons.rocket_launch,
                  label: AppLocalizations.of(context)!.get_started,
                  onPressed: () => Navigator.pushNamed(context, Routes.terms),
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
