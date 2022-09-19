import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(tr.loading_message),
      ),
    );
  }
}