import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_store.dart';

// TODO: This needs to be rewritten to use riverpod
class LoginPage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final AuthService authService = Provider.of<AuthService>(context);
    //final AuthService authService = context.read<AuthService>();
    // todo needs to include auth_store
    final AuthService authService = ref.watch(authProvider);

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