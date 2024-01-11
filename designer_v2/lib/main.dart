import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  /// See: https://stackoverflow.com/questions/57879455/flutter-catching-all-unhandled-exceptions
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await loadEnv();
    final sharedPreferences = await SharedPreferences.getInstance();
    runAsync(prefetchEmojiFont);

    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      // TODO: top-level error handling
      print("Exception: ${errorDetails.exception.toString()}");
      print("Stack: ${errorDetails.stack.toString()}");
    };
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    runApp(
        // Make dependencies managed by Riverpod available in Widget.build methods
        // by wrapping the app in a [ProviderScope]
        ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ], child: const App()));
  }, (error, stackTrace) {
    // TODO: top-level error handling
    print("Exception: ${error.toString()}");
    print("Stack: ${stackTrace.toString()}");
  });
}
