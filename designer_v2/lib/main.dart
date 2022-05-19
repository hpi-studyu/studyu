import 'package:flutter/material.dart';
import 'pages/my_app.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Future<void> main() async {
  await loadEnv();
  runApp(const MyApp());
}
