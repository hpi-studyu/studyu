import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'study_dashboard_screen.dart';

const isDebugMode = false;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => ThemeProvider(
          lightDynamic: lightDynamic,
          darkDynamic: darkDynamic,
          settings: settings,
          child: NotificationListener<ThemeSettingChange>(
            onNotification: (notification) {
              settings.value = notification.settings;
              return true;
            },
            child: ValueListenableBuilder<ThemeSettings>(
              valueListenable: settings,
              builder: (context, value, _) {
                // Create theme instance
                final theme = ThemeProvider.of(context);
                /*
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Flutter Demo',
                  theme: theme.light(settings.value.sourceColor),
                  darkTheme: theme.dark(settings.value.sourceColor), // Add this line
                  themeMode: theme.themeMode(), // Add this line
                  // Add theme
                  // Add dark theme
                  // Add theme mode
                  routeInformationParser: appRouter.routeInformationParser,
                  routerDelegate: appRouter.routerDelegate,
                );
                */

                return MaterialApp(
                    debugShowCheckedModeBanner: isDebugMode,
                    title: 'StudyU Designer',
                    theme: theme.light(settings.value.sourceColor),
                    home: const StudyDashboardScreen(),
                );
              },
            ),
          )),
    );
  }
}