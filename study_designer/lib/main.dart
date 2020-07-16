import 'package:flutter/material.dart';

import 'app.dart';
import 'environment.dart';

// Runs the dev/staging environment. Named main to make it easier to setup
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print('hi');
  runApp(Environment.development(child: MyApp()));
}
