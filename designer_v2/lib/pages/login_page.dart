import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_store.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: Text('Skip login'),
          onPressed: authService.skipLogin,
        )
      )
    );
  }
}