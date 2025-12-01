import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/services/rejoin_study_service.dart';
import 'package:studyu_core/core.dart';

class RejoinStudyScreen extends StatefulWidget {
  const RejoinStudyScreen({super.key});

  @override
  State<RejoinStudyScreen> createState() => _RejoinStudyScreenState();
}

class _RejoinStudyScreenState extends State<RejoinStudyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    13,
    (_) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;
  DateTime? _lastAttempt;
  final _cooldownDuration = const Duration(seconds: 5);

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getErrorMessage(String? errorKey) {
    final localizations = AppLocalizations.of(context)!;

    switch (errorKey) {
      case 'User not found':
        return localizations.recovery_user_not_found;
      case 'recovery_user_not_found':
        return localizations.recovery_user_not_found;
      case 'recovery_network_error':
        return localizations.recovery_network_error;
      case 'recovery_failed':
        return localizations.recovery_failed;
      default:
        return localizations.recovery_failed;
    }
  }

  void _validateAndSubmit() {
    // Rate limiting check
    if (_lastAttempt != null &&
        DateTime.now().difference(_lastAttempt!) < _cooldownDuration) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.recovery_rate_limit;
      });
      return;
    }
    _lastAttempt = DateTime.now();

    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final words = _controllers
          .map((c) => c.text.trim().toLowerCase())
          .toList();

      try {
        final id = RejoinStudyService.decodeRecoveryPhrase(words);
        _onSuccess(id);
      } catch (e) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invalid_recovery_phrase;
        });
      }
    }
  }

  Future<void> _onSuccess(BigInt id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await RejoinStudyService.performRecovery(id);

      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _errorMessage = _getErrorMessage(result.error);
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      if (result.subjectId != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.loading,
          (_) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.studySelection,
          (route) => route.settings.name == Routes.welcome,
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      StudyULogger.warning('Recovery error: $e\n$stackTrace');

      setState(() {
        _errorMessage = AppLocalizations.of(context)!.recovery_network_error;
        _isLoading = false;
      });
    }
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
                  crossAxisCount: 2,
                  childAspectRatio: 3.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 13,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      labelText: '${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    textInputAction: index < 12
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
                onPressed: _isLoading ? null : _validateAndSubmit,
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.recovery_in_progress,
                          ),
                        ],
                      )
                    : Text(AppLocalizations.of(context)!.rejoin_study),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
