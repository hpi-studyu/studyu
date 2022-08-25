import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/locale_translate_name.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

import 'auth/auth_controller.dart';
import 'auth/form_controller.dart';

class MainPageScaffold extends ConsumerStatefulWidget {
  final String childName;
  final Widget child;

  const MainPageScaffold({required this.child, Key? key, required this.childName}) : super(key: key);

  @override
  _MainPageScaffoldState createState() => _MainPageScaffoldState();
}

class _MainPageScaffoldState extends ConsumerState<MainPageScaffold> {

  @override
  void initState() {
    super.initState();
    ref.read(localeStateProvider.notifier).initLocale();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) => state.showResultUI(context),
    );

    return Scaffold(
        key: widget.key,
        //backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SizedBox(
                  height: height,
                  child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 2*height/12,
                          child: _topbar()
                        ),
                          SizedBox(
                            height: 8*height/12,
                            child: Column (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [widget.child],)
                            ),
                        SizedBox(
                          height: 2*height/12,
                          child: _bottombar(),
                        )
                      ]
                  ),
                )
            )
        )
    );
  }

  Widget _topbar() {
    return Row(
      //mainAxisSize: MainAxisSize.min,
      //textBaseline: TextBaseline.alphabetic,
      //mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 40), // todo make dynamic
          Column(
            //mainAxisAlignment: MainAxisAlignment.end,
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: GestureDetector(
                  onTap: () => ref.read(routerProvider).dispatch(RoutingIntents.root), // Image tapped
                  child: Image.asset('assets/images/icon_wide.png', fit: BoxFit.fitHeight,),
                ),),
                TextButton(
                    onPressed: () => ref.read(routerProvider).dispatch(
                        RoutingIntents.root),
                    child: Text('Designer', style: Theme.of(context).textTheme.headlineSmall /*style: FlutterFlowTheme.of(context).title1*/)
                ),
              ]
          ),
          const SizedBox(width: 40),
          InkWell(
            child: Text(tr.learn_more, style: Theme.of(context).textTheme.titleMedium,),
            onTap: () => launchUrl(Uri.parse('https://hpi.de/lippert/projects/studyu.html'.hardcoded)),
          ),
          const Spacer(),
          Container (
            child: showHeaderPromptText(),
          ),
          const SizedBox(width: 10),
          Container (
            child: showHeaderPromptLink(),
          ),
          const SizedBox(width: 40)
        ]
    );
  }

  Text? showHeaderPromptText() {
    if (widget.childName == 'login') {
      return Text(tr.no_account_yet, style: Theme.of(context).textTheme.titleMedium, /*style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,)*/);
    } else if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return Text(tr.an_account_yet, style: Theme.of(context).textTheme.titleMedium, /*style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,)*/);
    } else {
      return null;
    }
  }

  TextButton? showHeaderPromptLink() {
    if (widget.childName == 'login') {
      return TextButton(
        onPressed: () => ref.read(routerProvider).dispatch(RoutingIntents.signup),
        child: Text(tr.sign_up_here, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
      );
    } else if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return TextButton(
        onPressed: () => ref.read(routerProvider).dispatch(RoutingIntents.root),
        child: Text(tr.login_here, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
      );
    } else {
      return null;
    }
  }

  Widget _bottombar() {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);
    final localeState = ref.watch(localeStateProvider.notifier);

    final locForm = FormGroup({'localization': FormControl<Locale>(value: locale, validators: [Validators.required]),});

    return Column(
        children: [
          const Spacer(),
          Row(
              children: <Widget>[
                const SizedBox(width: 40),
                Container (
                    alignment: Alignment.centerLeft,
                    child: Text(tr.hpi_dhc,
                        /*style: TextStyle(
                            color: FlutterFlowTheme.of(context).alternate)*/
                    )
                ),
                const Spacer(),
                Container (
                  width: 150, // todo make this dynamic
                  alignment: Alignment.centerRight,
                  child: ReactiveForm(
                    formGroup: locForm,
                    child: ReactiveFormConsumer(builder: (context, form, child) {
                      return ReactiveDropdownField<Locale>(
                        formControlName: 'localization',
                        isExpanded: true,
                        items: dropdownItems(),
                        icon: const Icon(Icons.language),
                        onChanged: (loc) => localeState.setLocale(loc.value!),
                      );
                    }
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container (
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Text('Imprint'.
                    hardcoded, style: Theme.of(context).textTheme.titleMedium,),
                    onTap: () => launchUrl(appConfig.maybeWhen(data: (value) => Uri.parse(value.imprint[locale.languageCode] ?? ""), orElse: () => Uri.parse(''))),
                  ),
                ),
                const SizedBox(width: 40)
              ]
          ),
          const SizedBox(height: 20)
        ]
    );
  }

  static List<DropdownMenuItem<Locale>> dropdownItems() {
    List<DropdownMenuItem<Locale>> itemList = [];
    Config.supportedLocales.forEach((languageCode, countryCode) {
      final locale = Locale(languageCode, countryCode);
      itemList.add(
          DropdownMenuItem(value: locale,
            child: Text(
                '${_emojiFlag(countryCode)} '
                '${translateLocaleName(locale: locale)}'
            ),
          )
      );
    }
    );
    return itemList;
  }
  // Emoji flag sequences
  static String _emojiFlag(String country) {
    country = country.toUpperCase();

    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}
