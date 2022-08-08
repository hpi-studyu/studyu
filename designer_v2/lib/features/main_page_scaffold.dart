import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPageScaffold extends ConsumerStatefulWidget {

  final String childName;
  final Widget child;

  const MainPageScaffold({required this.child, Key? key, required this.childName}) : super(key: key);

  @override
  _MainPageScaffoldState createState() => _MainPageScaffoldState();
}

class _MainPageScaffoldState extends ConsumerState<MainPageScaffold> {
  bool formIsValid = false;
  bool tosAgreement = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: widget.key,
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SizedBox(
                  height: height,
                  child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: 0.5*height/12
                        ),
                        SizedBox(
                          height: 1*height/12,
                          child: _topbar(context),
                        ),
                        SizedBox(
                          height: 2*height/12,
                          child: _title(height),
                        ),
                        SizedBox(
                          width: 500,
                          height: 6*height/12,
                          child: widget.child,
                        ),
                        SizedBox(
                          height: 2.5*height/12,
                          child: _bottombar(context),
                        )
                      ]
                  ),
                )
            )
        )
    );
  }

  Widget _title(double height) {
    return Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => ref.read(routerProvider).dispatch(RoutingIntents.root), // Image tapped
          child: Image.asset('assets/images/icon_wide.png', fit: BoxFit.cover),
        )
    );
  }

  Widget _topbar(BuildContext context) {
    return Row(
        children: <Widget>[
          const SizedBox(width: 40),
          Container (
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () => ref.read(routerProvider).dispatch(
                      RoutingIntents.root),
                  child: Text('StudyU - Designer', style: FlutterFlowTheme.of(context).title1)
              ),
          ),
          const SizedBox(width: 20),
          Container (
              alignment: Alignment.centerLeft,
              child: InkWell(
                child: const Text('Learn more'),
                onTap: () => launchUrl(Uri.parse('https://hpi.de/lippert/projects/studyu.html'.hardcoded)),
              ),
          ),
          const Spacer(),
          Container (
            alignment: Alignment.centerRight,
            child: showHeaderPromptText(),
          ),
          const SizedBox(width: 10),
          Container (
            alignment: Alignment.centerRight,
            child: showHeaderPromptLink(),
          ),
          const SizedBox(width: 40)
        ]
    );
  }

  Text? showHeaderPromptText() {
    if (widget.childName == 'login') {
      return Text('Don\'t have an account?'.hardcoded, style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,));
    } else if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return Text('Already have an account?'.hardcoded, style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,));
    } else {
      return null;
    }
  }

  TextButton? showHeaderPromptLink() {
    if (widget.childName == 'login') {
      return TextButton(
        onPressed: () => ref.read(routerProvider).dispatch(RoutingIntents.signup),
        child: Text('Sign up here'.hardcoded, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
      );
    } else if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return TextButton(
        onPressed: () => ref.read(routerProvider).dispatch(RoutingIntents.root),
        child: Text('Login here'.hardcoded, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
      );
    } else {
      return null;
    }
  }

  Widget _bottombar(BuildContext context) {
    return Column(
        children: [
          const Spacer(),
          Row(
              children: <Widget>[
                const SizedBox(width: 40),
                Container (
                    alignment: Alignment.centerLeft,
                    child: Text('© HPI Digital Health Center 2022'.hardcoded,
                        style: TextStyle(
                            color: FlutterFlowTheme.of(context).alternate)
                    )
                ),
                const Spacer(),
                Container (
                  alignment: Alignment.centerRight,
                  child: Text('Language: English'.hardcoded,
                    style: TextStyle(color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container (
                    alignment: Alignment.centerRight,
                    child: Text('Imprint'.hardcoded,
                      style: TextStyle(color: FlutterFlowTheme.of(context).alternate,
                      ),
                    )
                ),
                const SizedBox(width: 40)
              ]
          ),
          const SizedBox(height: 20)
        ]
    );
  }

}