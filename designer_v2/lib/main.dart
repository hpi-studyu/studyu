import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'constants.dart';

Future<void> main() async {
  /// See: https://stackoverflow.com/questions/57879455/flutter-catching-all-unhandled-exceptions
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await loadEnv();
    runAsync(prefetchEmojiFont);

    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      // TODO: top-level error handling
      print("Exception: ${errorDetails.exception}");
      print("Stack: ${errorDetails.stack}");
    };
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    runApp(
      // Make dependencies managed by Riverpod available in Widget.build methods
      // by wrapping the app in a [ProviderScope]
      const ProviderScope(
            child: Portal(
                child: Portal(
      labels: [outPortalLabel],
      child: App(),
    ))),
    );
  }, (error, stackTrace) {
    // TODO: top-level error handling
    print("Exception: $error");
    print("Stack: $stackTrace");
  });
}
