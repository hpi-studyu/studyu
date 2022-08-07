import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import 'auth_controller.dart';

// todo make this file more dynamic with a StudyUForm creator that accepts a list of widgets

class ButtonWidget extends StatefulWidget {
  final bool isFormValid;
  final String buttonText;
  final Function onPressed;
  final WidgetRef ref;

  const ButtonWidget({required this.ref, required this.isFormValid, required this.buttonText, required this.onPressed, Key? key}) : super(key: key);

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final signupState = widget.ref.watch(authControllerProvider);
    return Center(
        child: Stack(children: <Widget>[
          PrimaryButton(
            isLoading: signupState.isLoading,
            onPressed: !signupState.isLoading && widget.isFormValid ?
                () => widget.onPressed() : null,
            text: widget.buttonText,
          ),
        ]
        )
    );
  }
}

class FieldValidators {
  static String? emailValidator(String? email) {
      if (email == null) {
        return null;
      }
      if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email)) {
        return 'Not a valid email';
      }
      return null;
  }
  static String? passwordValidator(String? password) {
    if (password == null || password.isEmpty || password.length < 6) {
      return 'Please enter a password with at least 6 characters';
    }
    return null;
  }
}

class TextFormFieldWidget extends StatefulWidget {
  final TextEditingController emailController;
  final String? Function(String?)? validator;

  const TextFormFieldWidget({required this.emailController, this.validator, Key? key}) : super(key: key);

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: widget.emailController,
              onChanged: (_) => (_),
              validator: widget.validator,
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
        )
    );
  }
}

class PasswordWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final String? Function(String?)? validator;

  const PasswordWidget({required this.passwordController, this.validator=FieldValidators.passwordValidator, Key? key}) : super(key: key);

  @override
  _PasswordWidgetState createState() => _PasswordWidgetState();
}
class _PasswordWidgetState extends State<PasswordWidget> {

  late bool passwordVisibility;

  @override
  void initState() {
    super.initState();
    passwordVisibility = false;
  }

  static String? passwordValidatorCustomized(String? password) {
    if (password == null || password.isEmpty || password.length < 6) {
      return 'Please enter a password with at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: widget.passwordController,
                onChanged: (_) => (_),
                autofocus: true,
                obscureText: !passwordVisibility,
                validator: widget.validator,
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
                  fillColor: FlutterFlowTheme
                      .of(context)
                      .lineColor,
                  suffixIcon: InkWell(
                    onTap: () =>
                        setState(
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
                style: FlutterFlowTheme
                    .of(context)
                    .bodyText1
                    .override( // todo fix
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w300,
                ),
              )
            ]
        )
    );
  }
}
