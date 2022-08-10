import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({Key? key}) : super(key: key);

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
            ReactiveTextField(
              formControlName: 'email',
              //autofocus: true, // todo disable only for mobile for all pages
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
                //fillColor: FlutterFlowTheme.of(context).lineColor,
              ),
              /*style: FlutterFlowTheme.of(context).bodyText1.override(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w300,
              ),*/
            )
          ],
        )
    );
  }
}

class PasswordWidget extends StatefulWidget {
  final String labelText;
  final String formControlName;

  // todo labelText is .hardcoded
  const PasswordWidget({Key? key, this.labelText='Password', this.formControlName='password'}) : super(key: key);

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
                  /*fillColor: FlutterFlowTheme
                      .of(context)
                      .lineColor,*/
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
                /*style: FlutterFlowTheme
                    .of(context)
                    .bodyText1
                    .override( // todo fix
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w300,
                ),*/
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
