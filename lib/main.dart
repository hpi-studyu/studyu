import 'package:flutter/material.dart';

import 'environments/dev.dart';

// Runs the dev/staging environment. Named main to make it easier to setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(devApp);
}
