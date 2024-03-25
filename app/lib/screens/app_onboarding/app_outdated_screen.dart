import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AppOutdatedScreen extends StatelessWidget {
  const AppOutdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    String? storeUrl;
    IconData? storeIcon;
    if (!kIsWeb && Platform.isAndroid) {
      storeUrl = playStoreUrl;
      storeIcon = MdiIcons.googlePlay;
    } else if (!kIsWeb && Platform.isIOS) {
      storeUrl = appstoreUrl;
      storeIcon = MdiIcons.apple;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              const Image(image: AssetImage('assets/icon/logo.png'), height: 200),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child:
                    Text(loc.app_outdated_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
              ),
              const Spacer(),
              storeUrl != null && storeIcon != null
                  ? OutlinedButton.icon(
                      icon: Icon(storeIcon),
                      onPressed: () async {
                        await launchUrl(Uri.parse(storeUrl!), mode: LaunchMode.externalNonBrowserApplication);
                      },
                      label: Text(loc.update_now, style: const TextStyle(fontSize: 20)),
                    )
                  : const SizedBox.shrink(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
