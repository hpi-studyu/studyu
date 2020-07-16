import 'package:flutter/material.dart';
import 'package:studyou_core/environment.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Environment.production(child: MyApp()));
}
