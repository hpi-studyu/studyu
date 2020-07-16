import 'package:flutter/material.dart';
import 'package:studyou_core/environment.dart';

import 'app.dart';

// Runs the dev/staging environment. Named main to make it easier to setup
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Environment.development(child: MyApp()));
}
