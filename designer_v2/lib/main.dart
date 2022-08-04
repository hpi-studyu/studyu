import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Future<void> main() async {
  await loadEnv();
  final sharedPreferences = await SharedPreferences.getInstance();

  /// See: https://stackoverflow.com/questions/57879455/flutter-catching-all-unhandled-exceptions
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      // TODO: top-level error handling
      print("Exception: ${errorDetails.exception.toString()}");
    };

    runApp(
      // Make dependencies managed by Riverpod available in Widget.build methods
      // by wrapping the app in a [ProviderScope]
      ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const App()
      )
    );
  }, (error, stackTrace) {
    // TODO: top-level error handling
    print("Exception: ${error.toString()}");
  });
}
