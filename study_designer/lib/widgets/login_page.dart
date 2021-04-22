import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/env.dart' as env;
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
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
                        obscureText: true,
                        validator: (value) => value.length >= 8 ? null : 'Password needs at least 8 characters',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          icon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            env.client.auth.signIn(email: _emailController.text, password: _passwordController.text);
                          }
                        },
                        label: Text('Login', style: TextStyle(fontSize: 20))),
                    SizedBox(width: 16),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            env.client.auth.signUp(_emailController.text, _passwordController.text);
                          }
                        },
                        child: Text('Sign Up', style: TextStyle(fontSize: 20))),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(MdiIcons.github),
                      onPressed: () async {
                        final res = await env.client.auth.signIn(
                          email: null,
                          password: null,
                          provider: Provider.github,
                          options: ProviderOptions(scopes: 'repo gist'),
                        );
                        launch(res.url);
                      },
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(MdiIcons.gitlab, color: const Color(0xfffc6d26)),
                      onPressed: () async {
                        final res = await env.client.auth.signIn(
                          email: null,
                          password: null,
                          provider: Provider.gitlab,
                          options: ProviderOptions(
                              //  This is not redundant
                              // ignore: avoid_redundant_argument_values
                              redirectTo: env.authRedirectToUrl,
                              scopes: 'api read_user read_api read_repository write_repository profile email'),
                        );
                        launch(res.url);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
