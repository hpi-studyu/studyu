import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../routes.dart';

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
              const Image(image: AssetImage('assets/images/icon_wide.png'), height: 200),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.info),
                onPressed: () => Navigator.pushNamed(context, Routes.about),
                label: Text(AppLocalizations.of(context)!.what_is_studyu, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.accountBox),
                onPressed: () => Navigator.pushNamed(context, Routes.contact),
                label: Text(AppLocalizations.of(context)!.contact, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.frequentlyAskedQuestions),
                onPressed: () => Navigator.pushNamed(context, Routes.faq),
                label: Text(AppLocalizations.of(context)!.faq, style: const TextStyle(fontSize: 20)),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.rocket, size: 30),
                onPressed: () => Navigator.pushNamed(context, Routes.terms),
                label: Text(AppLocalizations.of(context)!.get_started, style: const TextStyle(fontSize: 20)),
              ),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
