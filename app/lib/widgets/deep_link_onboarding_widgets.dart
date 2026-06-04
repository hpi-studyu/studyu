import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/env.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen shown to web users who open a deep link (invite or study).
///
/// On desktop web: Prompts the user to open the link on mobile.
/// On mobile web: Shows a "Download App" button that redirects to the appropriate store,
/// passing the invite code via referrer (Android) or clipboard (iOS).
class DeepLinkWebLandingPage extends StatefulWidget {
  final String? inviteCode;
  final String? studyId;

  const DeepLinkWebLandingPage({super.key, this.inviteCode, this.studyId})
    : assert(inviteCode != null || studyId != null);

  @override
  State<DeepLinkWebLandingPage> createState() => _DeepLinkWebLandingPageState();
}

class _DeepLinkWebLandingPageState extends State<DeepLinkWebLandingPage> {
  @override
  void initState() {
    super.initState();
    _launchAppScheme();
  }

  Future<void> _launchAppScheme() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final path = widget.inviteCode != null
        ? 'invite/${widget.inviteCode}'
        : 'study/${widget.studyId}';
    final link = generateAppSchemeLink(path);
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchAppStore() async {
    if (widget.inviteCode != null) {
      await _launchAppStoreForInvite(widget.inviteCode!);
    } else if (widget.studyId != null) {
      await _launchAppStoreForStudy(widget.studyId!);
    }
  }

  Future<void> _launchAppStoreForInvite(String inviteCode) async {
    // For iOS deferred deep linking via clipboard, we need the full valid URL
    final link = generateAppDeepLink("invite/$inviteCode");
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
        final link = generateAppDeepLink("invite/$inviteCode");
        await Clipboard.setData(ClipboardData(text: link));
        final url = Uri.parse("https://apps.apple.com/app/id$iosAppStoreId");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  Future<void> _launchAppStoreForStudy(String studyId) async {
    // Copy study deep link to clipboard, then open app store without referrer
    final link = generateAppDeepLink("studyShared/$studyId");
    await Clipboard.setData(ClipboardData(text: link));

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (androidPackageName != null) {
        final url = Uri.parse(
          "https://play.google.com/store/apps/details?id=$androidPackageName",
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
