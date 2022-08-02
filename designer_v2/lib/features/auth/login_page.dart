import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import '../../flutter_flow/flutter_flow_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool passwordVisibility;
  late bool rememberMeValue;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();

    rememberMeValue = true;
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordVisibility = false;
  }

  void _handleRememberme() {
    SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("remember_me", rememberMeValue);
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);
      },
    );
  }

  void _loadRememberMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email");
      var password = prefs.getString("password");
      var rememberMe = prefs.getBool("remember_me") ?? false;

      if (rememberMe) {
        setState(() {
          rememberMeValue = true;
        });
        emailController.text = email ?? "";
        passwordController.text = password ?? "";
      }
    } catch (e) {
      // todo catch error
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                    height: height,
                    child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 0.5*height/12
                          ),
                          SizedBox(
                            height: 1*height/12,
                            child: _topbar(),
                          ),
                          SizedBox(
                            height: 2*height/12,
                            child: _title(height),
                          ),
                          SizedBox(
                            width: 500,
                            height: 6*height/12,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            child: _formWidget(),
                          ),
                          SizedBox(
                            height: 2.5*height/12,
                            child: _bottombar(),
                          )
                        ]
                    ),
                )
            )
        )
    );
  }

  Widget _buttonWidget() {
    final authController = ref.watch(authControllerProvider.notifier);
    return Center(
        child: Stack(children: <Widget>[
      FFButtonWidget(
        onPressed: () {
          _handleRememberme();
          authController.signInWith(
              emailController.text, passwordController.text);
        },
        text: 'Sign In'.hardcoded,
        options: FFButtonOptions(
          width: 130,
          height: 40,
          color: FlutterFlowTheme.of(context).secondaryColor,
          textStyle: FlutterFlowTheme.of(context).bodyText1.override( // todo fix
                fontFamily: 'Roboto',
                color: FlutterFlowTheme.of(context).primaryBackground,
              ),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
          borderRadius: 30.0,
        ),
      ),
    ]));
  }

  Widget _rememberMeWidget() {
    return CheckboxListTile(
        value: rememberMeValue,
        onChanged: (newValue) =>
            setState(() {
              rememberMeValue = newValue!;
            }),
        title: Text(
          'Remember me'.hardcoded,
          style: FlutterFlowTheme.of(context).subtitle2.override( // todo fix
            fontFamily: 'Roboto',
            color: const Color(0xFF7B8995),
          ),
        )
    );
  }

  Widget _forgotPassword() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
            alignment: Alignment.centerLeft,
            child:
              Text('Forgot your password?'.hardcoded, style: FlutterFlowTheme.of(context).bodyText2,)
        )
    );
  }

  Widget _passwordWidget() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: passwordController,
                onChanged: (_) => (_),
                autofocus: true,
                obscureText: !passwordVisibility,
                decoration: InputDecoration(
                  labelText: 'Password'.hardcoded,
                  icon: const Icon(Icons.lock),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).lineColor,
                  suffixIcon: InkWell(
                    onTap: () => setState(
                      () => passwordVisibility = !passwordVisibility,
                    ),
                    focusNode: FocusNode(skipTraversal: true),
                    child: Icon(
                      passwordVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF757575),
                      size: 22,
                    ),
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyText1.override( // todo fix
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w300,
                    ),
              )
            ]));
  }

  Widget _emailWidget() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              onChanged: (_) => (_),
              autofocus: true,
              obscureText: false,
              decoration: InputDecoration(
                icon: const Icon(Icons.email),
                labelText: 'Email'.hardcoded,
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).lineColor,
              ),
              style: FlutterFlowTheme.of(context).bodyText1.override( // todo fix
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w300,
                  ),
            )
          ],
        ));
  }

  Widget _formWidget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text('Researcher Login'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
          const SizedBox(height: 20),
          _emailWidget(),
          _passwordWidget(),
          _rememberMeWidget(),
          _forgotPassword(),
          const SizedBox(height: 20),
          _buttonWidget(),
        ]
    );
  }

  Widget _title(double height) {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/icon_wide.png',
        height: height * 0.2,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _topbar() {
    return Row(
        children: <Widget>[
          const SizedBox(width: 40),
          Container (
              alignment: Alignment.centerLeft,
              child: Text('StudyU', style: FlutterFlowTheme.of(context).title1)
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

  Widget _bottombar() {
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
