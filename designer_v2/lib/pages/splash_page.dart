import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_service.dart';

// TODO: This needs to be rewritten to use riverpod
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
      body: const Center(
        child: Text("Loading..."),
      ),
    );
  }
}