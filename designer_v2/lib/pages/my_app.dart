import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import '../router.dart';
import '../services/app_service.dart';
import '../services/auth_store.dart';
import '../theme.dart';

import '../user.dart';

const isDebugMode = false;

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  final SupabaseClient supabaseClient;
  late AppDelegate appDelegate;
  late AuthService authService;

  MyApp({Key? key, required this.supabaseClient}) : super(key: key);

  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appDelegate = AppDelegate(ref.watch(sharedPreferencesProvider));
    authService = AuthService(supabaseClient: supabaseClient);
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
                debugShowCheckedModeBanner: isDebugMode,
                title: 'StudyU Designer V2',
                //color: appTheme.colorScheme.surface,
                //theme: appTheme,
                theme: ThemeData(primarySwatch: Colors.blue,),
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

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your phenomenal app"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("This is your homepage. Horray!"),
            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).logout();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Looks like you're not logged in. Let's change that."),
            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).login(
                  "myEmail",
                  "myPassword",
                );
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}