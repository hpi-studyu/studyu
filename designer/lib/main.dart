import 'package:flutter/material.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadEnv();

  runApp(MyApp());
}
