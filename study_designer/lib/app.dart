import 'package:flutter/material.dart';
import 'package:studyou_core/util/parse_init.dart';

import 'dashboard.dart';
import 'designer.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Designer',
      theme: theme,
      initialRoute: homeRoute,
      routes: {
        designerRoute: (_) => Designer(),
        homeRoute: (_) => ParseInit(child: Dashboard()),
      },
    );
  }
}
