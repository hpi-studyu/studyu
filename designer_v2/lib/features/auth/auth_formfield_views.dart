import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class EmailTextField extends StatefulWidget {
  const EmailTextField({Key? key}) : super(key: key);

  @override
  _EmailTextFieldState createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ReactiveTextField(
              formControlName: 'email',
              //autofocus: true, // todo disable only for mobile for all pages
              obscureText: false,
              decoration: InputDecoration(
                icon: const Icon(Icons.email),
                labelText: 'Email'.hardcoded,
              ),
            )
          ],
        )
    );
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    this.labelText='Password', // .hardcoded
    this.formControlName='password',
    Key? key
  }) : super(key: key);

  final String labelText;
  final String formControlName;

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}
class _PasswordTextFieldState extends State<PasswordTextField> {
  late bool passwordVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ReactiveTextField(
                formControlName: widget.formControlName,
                //autofocus: true,
                obscureText: !passwordVisibility,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  icon: const Icon(Icons.lock),
                  //filled: true,
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
              )
            ]
        )
    );
  }
}

formSuccessAction(BuildContext context, String successMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(successMessage)),
  );
}
