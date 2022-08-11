import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/services/notification_dispatcher.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_state.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends AuthState<App>  {

  @override
  Widget build(BuildContext context) {
    return const AppContent();
  }

  @override
  void initState() {
    super.initState();
    // todo move this to appController.onAppStart()
    final uriParameters = SupabaseAuth.instance.parseUriParameters(Uri.base);
    if (uriParameters.containsKey('access_token') &&
        uriParameters.containsKey('refresh_token') &&
        uriParameters.containsKey('expires_in')) {
      /// Uri.base is a auth redirect link
      /// Call recoverSessionFromUrl to continue
      recoverSessionFromUrl(Uri.base);
    }
  }
}

class AppContent extends ConsumerStatefulWidget {
  const AppContent({Key? key}) : super(key: key);

  @override
  _AppContentState createState() => _AppContentState();
}

class _AppContentState extends ConsumerState<AppContent> {
  late final AppController appController;

  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    //sourceColor: const Color(0xff2962ff),
    themeMode: ThemeMode.system,
  ));

  @override
  void initState() {
    super.initState();
    appController = ref.read(appControllerProvider.notifier);
    appController.onAppStart();
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => ThemeProvider(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            settings: settings,
            child: Builder(builder: (context) {
              final themeProvider = ThemeProvider.of(context);
              final theme = themeProvider.light(settings.value.sourceColor);
              return MaterialApp.router(
                scaffoldMessengerKey: scaffoldMessengerKey,
                builder: (context, widget) => NotificationDispatcher(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    navigatorKey: router.routerDelegate.navigatorKey,
                    child: widget
                ),
                debugShowCheckedModeBanner: Config.isDebugMode,
                title: 'Study Designer'.hardcoded,
                color: theme.colorScheme.surface,
                theme: theme,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  ...AppLocalizations.localizationsDelegates,
                  // See: https://github.com/danvick/flutter_form_builder/blob/master/packages/form_builder_validators/README.md#l10n
                  FormBuilderLocalizations.delegate,
                ],
                //routeInformationProvider: appRouter.routeInformationProvider, // for migration to v4
              );
            })
        )
    );
  }
}
