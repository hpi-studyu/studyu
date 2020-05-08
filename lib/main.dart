import 'Welcome/StudySelection.dart';
import 'Welcome/Welcome.dart';
import 'Welcome/About.dart';
import 'Dashboard/Dashboard.dart';

import 'package:flutter/material.dart';

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
