import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {

  @override
  void onUnauthenticated() {
    print('**********Unauthenticated');
  }

  @override
  void onAuthenticated(supabase.Session session) {
    print('**********Authenticated');
  }

  @override
  void onPasswordRecovery(supabase.Session session) {
    print('**********Password recovery');
  }

  @override
  void onErrorAuthenticating(String message) {
    print('***** onErrorAuthenticating: $message');
  }
}

