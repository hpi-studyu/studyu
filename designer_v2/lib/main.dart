import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/my_app.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:studyu_core/env.dart' as env;

Future<void> main() async {
  await loadEnv();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
      MyApp(sharedPreferences: sharedPreferences, supabaseClient: env.client)
  );
}
