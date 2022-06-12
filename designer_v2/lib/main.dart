import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'pages/designer.dart';

/*final sharedPref = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});*/

//final sharedPreferencesProvider = FutureProvider<SharedPreferences>((_) async => await SharedPreferences.getInstance());
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  //The return type Future<SharedPreferences> isn’t a ‘SharedPreferences’, as required by the closure’s context
  // https://codewithandrea.com/videos/flutter-state-management-riverpod
  throw UnimplementedError();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await loadEnv();

  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      overrides: [
        // override the previous value with the new object
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: Designer(supabaseClient: env.client),
    ),
  );
}
