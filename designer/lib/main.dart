import 'package:flutter/material.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import './util/register_web_webview_stub.dart'
  if (dart.library.html) './util/register_web_webview.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerWebViewWebImplementation();

  await loadEnv();

  runApp(MyApp());
}
