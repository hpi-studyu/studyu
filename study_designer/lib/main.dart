import 'package:flutter/material.dart';
import 'package:studyou_core/env.dart' as env;

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await env.loadEnv();

  runApp(MyApp());
}
