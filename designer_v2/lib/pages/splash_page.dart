import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({ Key? key }) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late AppDelegate _appDelegate;

  @override
  void initState() {
    _appDelegate = Provider.of<AppDelegate>(context, listen: false);
    onStartUp();
    super.initState();
  }

  void onStartUp() async {
    await _appDelegate.onAppStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Loading...'.hardcoded),
      ),
    );
  }
}