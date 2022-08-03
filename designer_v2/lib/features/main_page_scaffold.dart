import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class MainPageScaffold extends ConsumerStatefulWidget {

  final Widget child;

  const MainPageScaffold({required this.child, Key? key}) : super(key: key);

  @override
  _MainPageScaffoldState createState() => _MainPageScaffoldState();
}

class _MainPageScaffoldState extends ConsumerState<MainPageScaffold> {

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
                  child: Text('StudyU', style: FlutterFlowTheme.of(context).title1)
              ),
          ),
          const SizedBox(width: 20),
          Container (
              alignment: Alignment.centerLeft,
              child: Text('Learn more'.hardcoded,
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).primaryText)
              )
          ),
          const Spacer(),
          Container (
            alignment: Alignment.centerRight,
            child: Text('Don\'t have an account?'.hardcoded,
              style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container (
              alignment: Alignment.centerRight,
              child: Text('Sign up here'.hardcoded,
                style: TextStyle(color: FlutterFlowTheme.of(context).primaryText,
                ),
              )
          ),
          const SizedBox(width: 40)
        ]
    );
  }

  Widget _bottombar(BuildContext context) {
    return Column(
        children: [
          Spacer(),
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