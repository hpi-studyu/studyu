import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/app_service.dart';
import 'package:studyu_designer_v2/services/auth_store.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router.dart';

const isDebugMode = false;

class MyApp extends ConsumerStatefulWidget {
  final SharedPreferences sharedPreferences;
  final SupabaseClient supabaseClient;

  const MyApp(
      {Key? key, required this.sharedPreferences, required this.supabaseClient})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

late AppDelegate appDelegate;

final appDelegateProvider = ChangeNotifierProvider((ref) {
  return appDelegate;
});

class _MyAppState extends ConsumerState<MyApp> {
  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));

  @override
  void initState() {
    appDelegate = AppDelegate(widget.sharedPreferences);
    AuthStore.supabaseClient = widget.supabaseClient;
    // todo use appDelegateProvider instead
    ref.read(authServiceProvider).delegate = appDelegate;
    ref.read(routerNotifierProvider).delegate = appDelegate;
    super.initState();
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
            })));
  }
}
