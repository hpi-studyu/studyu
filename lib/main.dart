import 'package:flutter/material.dart';

import 'dashboard/dashboard.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nof1 Initial app',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "welcome",
      routes: <String, WidgetBuilder>{
        "welcome": (context) => WelcomeScreen(),
        "about": (context) => AboutScreen(),
        "studySelection": (context) => StudySelectionScreen(),
        "dashboard": (context) => DashboardScreen(),
      },
    );
  }
}
