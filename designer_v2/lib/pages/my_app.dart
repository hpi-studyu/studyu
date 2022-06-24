import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_designer_v2/router.dart';
import 'package:studyu_designer_v2/services/app_delegate.dart';
import 'package:studyu_designer_v2/theme.dart';

const isDebugMode = false;

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late AppDelegate appDelegate;

  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));

  @override
  void initState() {
    super.initState();
    appDelegate = AppDelegate(ref.read(sharedPreferencesProvider));
    appDelegate.onAppStart();
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(routerProvider);

    return DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => ThemeProvider(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            settings: settings,
            child: Builder(builder: (context) {
              final themeProvider = ThemeProvider.of(context);
              final appTheme = themeProvider.light(settings.value.sourceColor);

              return MaterialApp.router(
                debugShowCheckedModeBanner: isDebugMode,
                title: 'StudyU Designer'.hardcoded,
                color: appTheme.colorScheme.surface,
                theme: appTheme,
                routeInformationParser: appRouter.routeInformationParser,
                routerDelegate: appRouter.routerDelegate,
                //routeInformationProvider: appRouter.routeInformationProvider, // for migration to v4
              );
            })
        )
    );
  }
}
