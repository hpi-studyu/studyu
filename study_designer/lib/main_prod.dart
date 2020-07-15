import 'package:flutter/material.dart';

import 'app.dart';
import 'environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Environment.production(child: MyApp()));
}
