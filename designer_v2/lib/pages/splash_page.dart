import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

import '../services/app_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  final AppDelegate delegate;

  SplashPage(this.delegate);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late AppDelegate _appDelegate;

  @override
  void initState() {
    _appDelegate = widget.delegate;
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
