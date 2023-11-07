import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:studyu_designer_v2/localization/app_translation.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context)!.loading_message),
        // tr leads to unexpected null value, splash screen probably skips too fast
        // child: Text(tr.loading_message),
      ),
    );
  }
}
