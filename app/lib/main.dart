import 'package:flutter/material.dart';

import 'environments/dev.dart';

// Runs the dev/staging environment. Named main to make it easier to setup
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print('hi');
  runApp(devApp);
}
