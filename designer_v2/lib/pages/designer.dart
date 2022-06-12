import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';

import '../main.dart';
import '../router.dart';
import '../services/app_service.dart';
import '../services/auth_store.dart';
import '../theme.dart';

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class Designer extends ConsumerWidget {
  final SupabaseClient supabaseClient;
  late AppDelegate appDelegate;
  late AuthService authService;

  Designer({Key? key, required this.supabaseClient}) : super(key: key);

  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appDelegate = AppDelegate(ref.watch(sharedPreferencesProvider));

    //AuthRepository authRepository = AuthRepository(supabaseClient: supabaseClient);
    //authService = AuthRepository(supabaseClient: supabaseClient);
    //ref.read(authProvider.state).state = supabaseClient;

    // todo Is delegate necessary with riverpod?
    authService = AuthService();
    authService.delegate = appDelegate;

    //final theme = ThemeProvider.of(context);
    final router = ref.watch(routerProvider);

    //return MaterialApp(home: Scaffold(appBar: AppBar(title: const Text('Example')), body: const Center(child: Text("hi"),),),);
    /*  return */
    /*DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => ThemeProvider(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            settings: settings,
            child: Builder(builder: (context) {
              final themeProvider = ThemeProvider.of(context);
              final appTheme = themeProvider.light(settings.value.sourceColor);
              //final appRouter = Provider.of<AppRouter>(context, listen: false).router;
              //final appRouter = context.read<AppRouter>().router;

              return*/
    return MaterialApp.router(
      debugShowCheckedModeBanner: kDebugMode,
      title: 'StudyU Designer V2',
      //color: appTheme.colorScheme.surface,
      //theme: appTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
    /*
                  return MaterialApp(
                    debugShowCheckedModeBanner: isDebugMode,
                    title: 'StudyU Designer',
                    theme: appTheme.light(settings.value.sourceColor),
                    home: const StudyDashboardScreen(),
              );*/
  }
}
