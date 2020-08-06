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
  final routes = {
    designerRoute: (_) => Designer(route: designerRoute),
    homeRoute: (_) => ParseInit(child: Dashboard()),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Designer',
      theme: theme,
      onGenerateRoute: (settings) {
        if (settings.name.startsWith(designerRoute)) {
          return MaterialPageRoute(builder: (_) => Designer(route: settings.name), settings: settings);
        }
        // Go back to home, if route not found
        if (!routes.containsKey(settings.name)) {
          return MaterialPageRoute(builder: routes[homeRoute]);
        }
        return MaterialPageRoute(builder: routes[settings.name], settings: settings);
      },
    );
  }
}
