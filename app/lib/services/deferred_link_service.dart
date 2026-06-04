import 'package:flutter/foundation.dart';
import 'package:stack_deferred_link/stack_deferred_link.dart';
import 'package:studyu_core/env.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

@visibleForTesting
String deferredInviteDeepLinkHost(String? configuredDeepLinkScheme) {
  final scheme = configuredDeepLinkScheme ?? 'https://app.studyu.health';
  return Uri.parse(scheme).host;
}

class DeferredLinkService {
  static Future<String?> checkForDeferredLink() async {
    try {
      final hasProcessed =
          await SecureStorage.readBool('has_processed_deferred_link') ?? false;
      if (hasProcessed) {
        await SecureStorage.write(
          'debug_install_referrer',
          'Check skipped: has_processed_deferred_link is true',
        );
        return null;
      }

      String? deferredCode;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await StackDeferredLink.getInstallReferrerAndroid();
        final referrer = info.installReferrer; // capture to local for promotion
        await SecureStorage.write(
          'debug_install_referrer',
          'Raw: $referrer\nParams: ${info.asQueryParameters}',
        );
        deferredCode = info.getParam('invite_code');

        // [FIX ATTEMPT 1] Fallback: manual parsing if getParam fails
        if (deferredCode.isEmpty && referrer != null) {
          final uri = Uri.tryParse('?$referrer');
          if (uri != null) {
            final manualCode = uri.queryParameters['invite_code'];
            if (manualCode != null && manualCode.isNotEmpty) {
              deferredCode = manualCode;
              await SecureStorage.write(
                'debug_install_referrer',
                'Status: Manual parsing triggered.\nExtracted Code: $deferredCode',
              );
            }
          }
        }

        // [FIX ATTEMPT 2] "Dirty" string parsing if still null (just in case)
        if (deferredCode.isEmpty &&
            referrer != null &&
            referrer.contains('invite_code=')) {
          try {
            // Split by '&' or just regex find
            final regexp = RegExp('invite_code=([^&]+)');
            final match = regexp.firstMatch(referrer);
            if (match != null) {
              deferredCode = match.group(1);
              await SecureStorage.write(
                'debug_install_referrer',
                'Status: Regex parsing triggered.\nExtracted Code: $deferredCode',
              );
            }
          } catch (e) {
            // ignore
          }
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final scheme = appDeepLinkScheme ?? 'https://app.studyu.health';
        final host = Uri.parse(scheme).host;
        await SecureStorage.write(
          'debug_install_referrer',
          'iOS Check. Host: $host',
        );

        final result = await StackDeferredLink.getInstallReferrerIos(
          deepLinks: ['$host/invite'],
        );

        await SecureStorage.write(
          'debug_install_referrer',
          'iOS Result: ${result?.fullReferralDeepLinkPath}',
        );

        if (result != null) {
          final uri = Uri.tryParse(result.fullReferralDeepLinkPath);
          if (uri != null && uri.pathSegments.contains('invite')) {
            final idx = uri.pathSegments.indexOf('invite');
            if (idx + 1 < uri.pathSegments.length) {
              deferredCode = uri.pathSegments[idx + 1];
            }
          }
        }
      }

      deferredCode = _sanitizeCode(deferredCode);

      if (deferredCode != null) {
        await SecureStorage.write('has_processed_deferred_link', 'true');
        return deferredCode;
      }
      // Add else block for debugging empty code
      else {
        await SecureStorage.write(
          'debug_install_referrer',
          'Code parsed but empty or null. Final code: $deferredCode',
        );
      }
    } catch (e) {
      debugPrint("Deferred link check failed: $e");
      // debug error
      await SecureStorage.write('debug_install_referrer', 'Error: $e');
    }
    return null;
  }

  static String? _sanitizeCode(String? code) {
    if (code == null) return null;
    var sanitized = code.trim();
    if (sanitized.isEmpty) return null;

    try {
      sanitized = Uri.decodeComponent(sanitized);
    } catch (_) {
      // ignore
    }
    return sanitized.trim();
  }
}
