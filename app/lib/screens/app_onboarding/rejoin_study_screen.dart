import 'package:flutter/material.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/src/util/recovery.dart';
import 'package:studyu_core/src/util/wordlists.dart';

class RejoinStudyScreen extends StatefulWidget {
  const RejoinStudyScreen({super.key});

  @override
  State<RejoinStudyScreen> createState() => _RejoinStudyScreenState();
}

class _RejoinStudyScreenState extends State<RejoinStudyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    7,
    (_) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final words = _controllers
          .map((c) => c.text.trim().toLowerCase())
          .toList();

      try {
        try {
          final id = decode(words, wordlist: WORDLIST_EN);
          _onSuccess(id);
          return;
        } catch (e) {
          try {
            final id = decode(words, wordlist: WORDLIST_DE);
            _onSuccess(id);
            return;
          } catch (e2) {
            setState(() {
              _errorMessage = AppLocalizations.of(
                context,
              )!.invalid_recovery_phrase;
            });
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onSuccess(BigInt id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.recovery_successful(id.toString()),
        ),
      ),
    );
    context.goNamed(Routes.loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.rejoin_study)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.enter_recovery_phrase,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      labelText: '${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    textInputAction: index < 6
                        ? TextInputAction.next
                        : TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.contains(' ')) {
                        final words = value.trim().split(RegExp(r'\s+'));
                        if (words.length > 1) {
                          for (int i = 0; i < words.length; i++) {
                            if (index + i < _controllers.length) {
                              _controllers[index + i].text = words[i];
                            }
                          }
                        }
                      }
                    },
                  );
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _validateAndSubmit,
                child: Text(AppLocalizations.of(context)!.rejoin_study),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
