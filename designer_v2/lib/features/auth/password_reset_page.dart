import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/auth/auth_controller.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import 'package:studyu_designer_v2/flutter_flow/flutter_flow_widgets.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  late TextEditingController emailController;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return _formWidget();
  }

  Widget _formWidget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text('Researcher Password Reset'.hardcoded, style: FlutterFlowTheme.of(context).title1,)),
          const SizedBox(height: 20),
          _emailWidget(),
          const SizedBox(height: 20),
          _buttonWidget(),
        ]
    );
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

  Widget _buttonWidget() {
    final authController = ref.watch(authControllerProvider.notifier);
    return Center(
        child: Stack(children: <Widget>[
          FFButtonWidget(
            onPressed: () {
              authController.resetPasswordForEmail(
                  emailController.text);
            },
            text: 'Reset Password'.hardcoded,
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
}
