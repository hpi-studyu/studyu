import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/qr_code_scanner_screen.dart';
import 'package:studyu_app/services/rejoin_study_service.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
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
  List<String> _words = [];
  bool get _hasTooManyWords => _words.length > RecoveryConstants.totalWordCount;
  bool get _canSubmitPhrase =>
      !_isLoading && _words.length == RecoveryConstants.totalWordCount;

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

  Future<void> _scanQrCode() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScannerScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _phraseController.text = result.join(' ');
      });
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;
    final words = _words.map((w) => w.trim().toLowerCase()).toList();

    if (words.length != RecoveryConstants.totalWordCount) {
      setState(() {
        _errorMessage = words.length > RecoveryConstants.totalWordCount
            ? localizations.recovery_phrase_too_many_words
            : localizations.invalid_recovery_phrase;
      });
      return;
    }

    try {
      final id = RejoinStudyService.decodeRecoveryPhrase(words);
      _onSuccess(id);
    } catch (e) {
      setState(() {
        _errorMessage = localizations.invalid_recovery_phrase;
      });
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
        context.goNamed(RouteNames.loading);
      } else {
        context.goNamed(RouteNames.studySelection);
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
      body: OnboardingPage(
        title: AppLocalizations.of(context)!.enter_recovery_phrase,
        description: AppLocalizations.of(context)!.rejoin_study_description,
        maxWidth: 900,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                          const Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.rejoin_study_help_title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final phraseField = TextFormField(
                    controller: _phraseController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.enter_recovery_phrase,
                      hintText: 'apple banana cherry ...',
                      border: const OutlineInputBorder(),
                      helperText: _hasTooManyWords
                          ? AppLocalizations.of(
                              context,
                            )!.recovery_phrase_too_many_words
                          : '${_words.length}/${RecoveryConstants.totalWordCount} words',
                      helperStyle: TextStyle(
                        color: _hasTooManyWords
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                      suffixIcon:
                          _words.length == RecoveryConstants.totalWordCount
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    maxLines: 4,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (_canSubmitPhrase) _validateAndSubmit();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.required;
                      }
                      if (_hasTooManyWords) {
                        return AppLocalizations.of(
                          context,
                        )!.recovery_phrase_too_many_words;
                      }
                      return null;
                    },
                  );

                  final scanButton = SizedBox.square(
                    dimension: 120,
                    child: OutlinedButton(
                      onPressed: _scanQrCode,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_scanner),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.scan_qr_code,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );

                  final orText = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  );

                  if (constraints.maxWidth < 700) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        phraseField,
                        const SizedBox(height: 12),
                        Center(child: orText),
                        const SizedBox(height: 12),
                        scanButton,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: phraseField),
                      SizedBox(height: 120, child: Center(child: orText)),
                      scanButton,
                    ],
                  );
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _canSubmitPhrase ? _validateAndSubmit : null,
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
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
      bottomNavigationBar: BottomOnboardingNavigation(
        hideNext: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(RouteNames.welcome);
          }
        },
      ),
    );
  }
}
