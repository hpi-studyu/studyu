import 'package:flutter/material.dart';
import 'package:studyou_core/util/parse_init.dart';

import 'dashboard.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Study Designer', theme: theme, home: ParseInit(child: Dashboard()));
  }
}
