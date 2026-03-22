import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/env.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen shown to web users who open an invite link.
///
/// On desktop web: Prompts the user to open the link on mobile.
/// On mobile web: Shows a "Download App" button that redirects to the appropriate store,
/// passing the invite code via referrer (Android) or clipboard (iOS).
class DeepLinkWebLandingPage extends StatelessWidget {
  final String inviteCode;

  const DeepLinkWebLandingPage({super.key, required this.inviteCode});

  Future<void> _launchAppStore() async {
    final link = "$appDeepLinkScheme/invite/$inviteCode";
    await Clipboard.setData(ClipboardData(text: link));

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (androidPackageName != null) {
        final referrer = Uri.encodeComponent("invite_code=$inviteCode");
        final url = Uri.parse(
          "https://play.google.com/store/apps/details?id=$androidPackageName&referrer=$referrer",
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (iosAppStoreId != null) {
        final url = Uri.parse("https://apps.apple.com/app/id$iosAppStoreId");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are on a mobile browser
    final isMobile =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (!isMobile) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.open_link_on_mobile,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.you_have_been_invited,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: _launchAppStore,
              child: Text(AppLocalizations.of(context)!.download_app_join),
            ),
          ],
        ),
      ),
    );
  }
}

/// A banner widget shown on the Welcome Screen when a pending invite code is detected.
class PendingInviteBanner extends StatelessWidget {
  const PendingInviteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MdiIcons.ticketConfirmation,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.you_have_been_invited,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
