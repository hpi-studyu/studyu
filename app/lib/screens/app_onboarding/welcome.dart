import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/debug_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                icon: const Icon(Icons.info),
                onPressed: () => context.push('/${RouteNames.about}'),
                label: Text(
                  AppLocalizations.of(context)!.what_is_studyu,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.accountBox),
                onPressed: () => context.push('/${RouteNames.contact}'),
                label: Text(
                  AppLocalizations.of(context)!.contact,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.frequentlyAskedQuestions),
                onPressed: () => context.push('/${RouteNames.faq}'),
                label: Text(
                  AppLocalizations.of(context)!.faq,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.rocket, size: 30),
                onPressed: () => context.push('/${RouteNames.terms}'),
                label: Text(
                  AppLocalizations.of(context)!.get_started,
                  style: const TextStyle(fontSize: 20),
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
