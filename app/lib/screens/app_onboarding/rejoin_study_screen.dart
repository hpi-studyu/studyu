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
  final TextEditingController _phraseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;
  DateTime? _lastAttempt;
  final _cooldownDuration = const Duration(seconds: 5);
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _phraseController.addListener(_onPhraseChanged);
  }

  @override
  void dispose() {
    _phraseController.removeListener(_onPhraseChanged);
    _phraseController.dispose();
    super.dispose();
  }

  void _onPhraseChanged() {
    setState(() {
      _words = _phraseController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
    });
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
      final words = _words.map((w) => w.trim().toLowerCase()).toList();

      if (words.length != 13) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invalid_recovery_phrase;
        });
        return;
      }

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

  Widget _buildHelpItem(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
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
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.rejoin_study_description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.rejoin_study_help_title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildHelpItem(
                        context,
                        Icons.list_alt,
                        AppLocalizations.of(context)!.rejoin_study_help_1,
                      ),
                      const SizedBox(height: 8),
                      _buildHelpItem(
                        context,
                        Icons.content_paste,
                        AppLocalizations.of(context)!.rejoin_study_help_2,
                      ),
                      const SizedBox(height: 8),
                      _buildHelpItem(
                        context,
                        Icons.text_fields,
                        AppLocalizations.of(context)!.rejoin_study_help_3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Single Text Input Field with validation feedback
              TextFormField(
                controller: _phraseController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.enter_recovery_phrase,
                  hintText: 'apple banana cherry ...',
                  border: const OutlineInputBorder(),
                  helperText: '${_words.length}/13 words',
                  helperStyle: TextStyle(
                    color: _words.length == 13
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: _words.length == 13
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  suffixIcon: _words.length == 13
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _validateAndSubmit(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.required;
                  }
                  return null;
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
