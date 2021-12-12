import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:studyu_designer/models/app_state.dart';
import 'package:studyu_designer/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends SupabaseAuthState<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    recoverSupabaseSession();
  }

  void _login(AppState appState) {
    if (_formKey.currentState.validate()) {
      appState.signIn(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage('assets/images/icon_wide.png'), height: 200),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) => EmailValidator.validate(email) ? null : 'Please enter a valid email',
                          decoration: InputDecoration(
                            labelText: 'Email',
                            icon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: true,
                          validator: (value) => value.length >= 8 ? null : 'Password needs at least 8 characters',
                          decoration: InputDecoration(
                            labelText: 'Password',
                            icon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (value) => _login(appState),
                        ),
                      ],
                    ),
                  ),
                ),
                if (appState.authError != null) ...[
                  SizedBox(height: 24),
                  Text(appState.authError, style: theme.textTheme.subtitle1.copyWith(color: Colors.red)),
                ],
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 6,
                      child: OutlinedButton.icon(
                          icon: Icon(Icons.login),
                          onPressed: () => _login(appState),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text('Login', style: TextStyle(fontSize: 20)),
                          )),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 6,
                      child: OutlinedButton.icon(
                          icon: Icon(MdiIcons.accountPlus),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              appState.signUp(_emailController.text, _passwordController.text);
                            }
                          },
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text('Sign Up', style: TextStyle(fontSize: 20)),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text('Login with', style: theme.textTheme.headline5),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      label: Text('GitLab'),
                      style: OutlinedButton.styleFrom(primary: gitlabColor),
                      icon: Icon(MdiIcons.gitlab),
                      onPressed: () => appState.signInWithProvider(
                          Provider.gitlab, 'api read_user read_api read_repository write_repository profile email'),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => appState.skipLogin(),
                  child: Text('Skip login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onAuthenticated(Session session) {}

  @override
  void onErrorAuthenticating(String message) {}

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onUnauthenticated() {}
}
