import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/pages/my_app.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Future<void> main() async {
  await loadEnv();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    // Make dependencies managed by Riverpod available in Widget.build methods
    // by wrapping the app in a [ProviderScope]
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: App()
    )
  );
}
