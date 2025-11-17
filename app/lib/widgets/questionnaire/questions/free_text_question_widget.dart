import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/speech/speech_to_text_controller.dart';
import 'package:studyu_app/services/speech/speech_to_text_language.dart';
import 'package:studyu_app/services/speech/speech_to_text_preferences.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';

import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;

  const FreeTextQuestionWidget({
    super.key,
    required this.question,
    this.onDone,
  });

  @override
  State<FreeTextQuestionWidget> createState() => _FreeTextQuestionWidgetState();
}

class _FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final _textFieldController = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();
  bool _hasInteracted = false;
  bool _hasSubmitted = false;
  Timer? _debounceTimer;
  Timer? _listeningRestartTimer;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  SpeechToTextController? _speechController;
  bool _speechPrefsRequested = false;
  bool _speechPrefsInitialized = false;
  bool _listeningRequested = false;
  SpeechErrorType? _lastSpeechErrorType;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_speechPrefsRequested && SpeechToTextController.isSupportedPlatform) {
      _speechPrefsRequested = true;
      _initSpeechPreferences();
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _listeningRestartTimer?.cancel();
    _speechController?.removeListener(_onSpeechStateChanged);
    _speechController?.dispose();
    super.dispose();
  }

  Future<void> _initSpeechPreferences() async {
    final fallbackLocale = Localizations.maybeLocaleOf(context);
    final language = await SpeechToTextPreferences.preferredLanguage(
      fallbackLocale: fallbackLocale,
    );
    if (!mounted) return;
    setState(() {
      _speechPrefsInitialized = true;
    });
    _createSpeechController(language);
  }

  void _createSpeechController(SpeechRecognitionLanguage language) {
    _speechController?.removeListener(_onSpeechStateChanged);
    _speechController?.dispose();
    _speechController = SpeechToTextController(
      onFinalTranscription: _insertSpeechTranscript,
      initialLanguage: language,
      context: context,
    );
    _speechController!.addListener(_onSpeechStateChanged);
    _listeningRequested = false;
    setState(() {});
  }

  void _onSpeechStateChanged() {
    final controller = _speechController;
    if (controller == null) return;
    final state = controller.value;
    final currentError = controller.value.error;
    if (currentError != null && currentError.type != _lastSpeechErrorType) {
      final loc = AppLocalizations.of(context)!;
      final message = _mapSpeechErrorToMessage(currentError, loc);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
    _lastSpeechErrorType = currentError?.type;
    if (!mounted) return;
    final isIdleOrReady = state.status == SpeechLifecycleStatus.idle ||
        state.status == SpeechLifecycleStatus.ready;
    final hasError = state.error != null;
    if (hasError && _listeningRequested) {
      _setListeningRequested(false);
    }
    final shouldRestart =
        _listeningRequested && isIdleOrReady && !hasError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      if (shouldRestart) {
        _scheduleListeningRestart();
      } else if (state.error != null || !_listeningRequested) {
        _listeningRestartTimer?.cancel();
      }
    });
  }

  void _insertSpeechTranscript(String transcript) {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) return;
    final controller = _textFieldController;
    final selection = controller.selection;
    final baseOffset = selection.isValid
        ? selection.extentOffset
        : controller.text.length;
    final currentText = controller.text;
    final previousChar = baseOffset > 0
        ? currentText.substring(baseOffset - 1, baseOffset)
        : '';
    final needsSpace = previousChar.trim().isNotEmpty;
    final insertion = '${needsSpace ? ' ' : ''}$trimmed';
    final newText = currentText.replaceRange(baseOffset, baseOffset, insertion);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: baseOffset + insertion.length),
    );
    _handleInteraction();
    _debouncedValidation();
  }

  String? _mapSpeechErrorToMessage(SpeechError error, AppLocalizations loc) {
    final details = error.details?.toLowerCase();
    final isPermissionIssue = details?.contains('permission') == true;
    if (error.type == SpeechErrorType.microphonePermission &&
        isPermissionIssue) {
      return loc.speech_to_text_error_permission;
    }
    return loc.speech_to_text_error_general;
  }

  void _toggleSpeechListening() {
    if (_listeningRequested) {
      _stopListeningIntent();
    } else {
      _setListeningRequested(true);
      unawaited(_startListeningIfRequested());
    }
  }

  void _stopListeningIntent() {
    _setListeningRequested(false);
    _listeningRestartTimer?.cancel();
    unawaited(_stopActiveListening());
  }

  void _setListeningRequested(bool requested) {
    if (_listeningRequested == requested) return;
    _listeningRequested = requested;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _scheduleListeningRestart() {
    if (!_listeningRequested) return;
    final controller = _speechController;
    if (controller == null) return;
    final state = controller.value;
    final readyForRestart = state.error == null &&
        (state.status == SpeechLifecycleStatus.idle ||
            state.status == SpeechLifecycleStatus.ready);
    if (!readyForRestart) {
      return;
    }
    _listeningRestartTimer?.cancel();
    _listeningRestartTimer = Timer(const Duration(milliseconds: 250), () {
      if (!_listeningRequested) return;
      final restartController = _speechController;
      if (restartController == null) return;
      final restartState = restartController.value;
      final canRestart = restartState.error == null &&
          (restartState.status == SpeechLifecycleStatus.idle ||
              restartState.status == SpeechLifecycleStatus.ready);
      if (!canRestart) {
        return;
      }
      unawaited(_startListeningIfRequested());
    });
  }

  Future<void> _startListeningIfRequested() async {
    final controller = _speechController;
    if (_listeningRequested == false || controller == null) {
      return;
    }

    var state = controller.value;
    var status = state.status;

    if (status == SpeechLifecycleStatus.listening ||
        status == SpeechLifecycleStatus.preparing ||
        status == SpeechLifecycleStatus.unavailable) {
      return;
    }

    if (status == SpeechLifecycleStatus.error) {
      await controller.forceReset();
      state = controller.value;
      status = state.status;
    }

    final canStart =
        status == SpeechLifecycleStatus.idle || status == SpeechLifecycleStatus.ready;
    if (!canStart) {
      return;
    }

    await controller.startListening();
  }

  Future<void> _stopActiveListening() async {
    final controller = _speechController;
    if (controller == null) return;
    await controller.stopListening();
  }

  Widget _buildSpeechAssistant(ThemeData theme, AppLocalizations loc) {
    if (!SpeechToTextController.isSupportedPlatform) {
      return _speechInfoCard(loc.speech_to_text_unsupported, theme);
    }
    if (!_speechPrefsInitialized) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    final controller = _speechController;
    if (controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<SpeechControllerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final isListening = state.status == SpeechLifecycleStatus.listening;
        final isPreparing = state.status == SpeechLifecycleStatus.preparing;
        final statusLabel = isListening
            ? loc.speech_to_text_listening
            : loc.speech_to_text_press_to_speak;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _buildSpeechToggleButton(
                theme,
                loc,
                isListening,
                isPreparing,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                statusLabel,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (isPreparing) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              Text(
                loc.speech_to_text_preparing,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if ((state.partialTranscript ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${loc.speech_to_text_live_caption_hint}: ${state.partialTranscript!}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            if (state.status == SpeechLifecycleStatus.error &&
                state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _mapSpeechErrorToMessage(state.error!, loc) ??
                      loc.speech_to_text_error_general,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSpeechToggleButton(
    ThemeData theme,
    AppLocalizations loc,
    bool isListening,
    bool isPreparing,
  ) {
    final disabled = isPreparing;
    final active = _listeningRequested && !disabled;
    final circleColor = disabled
        ? theme.colorScheme.surfaceContainerHighest
        : active
            ? theme.colorScheme.primary
            : theme.colorScheme.surface;
    final iconColor = disabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
        : active
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary;
    final borderColor = active
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;
    final iconData = active || isListening ? Icons.pause : Icons.mic;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : _toggleSpeechListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: 30,
        ),
      ),
    );
  }

  Widget _speechInfoCard(String text, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: theme.textTheme.bodySmall),
      ),
    );
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _ensureTextFieldVisible();
    } else {
      // When focus is lost, handle auto-submit if applicable
      _handleAutoSubmit();
    }
  }

  Future<void> _ensureTextFieldVisible() async {
    final keyContext = _formFieldKey.currentContext;
    await Future.delayed(const Duration(milliseconds: 500));
    if (keyContext != null && context.mounted) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
        alignment: 0.5, // Center the text field in the viewport
      );
    }
  }

  void _handleAutoSubmit() {
    if (_hasInteracted && !_hasSubmitted) {
      _handleSubmit();
    } else {
      FocusScope.of(context).unfocus();
      // Reset interaction and submission state for potential future edits
      _hasInteracted = false;
      _hasSubmitted = false;
      setState(() {
        _autovalidateMode = AutovalidateMode.disabled;
      });
    }
  }

  void _handleSubmit([String? value]) {
    FocusScope.of(context).unfocus();
    final text = value ?? _textFieldController.text;
    _validateAndSubmit(text);
  }

  void _validateAndSubmit(String value) {
    if (_formFieldKey.currentState?.validate() == true) {
      widget.onDone?.call(widget.question.constructAnswer(value));
      _hasSubmitted = true;
    }
  }

  void _handleInteraction() {
    if (!_hasInteracted) {
      _hasInteracted = true;
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }

  void _debouncedValidation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _hasInteracted) {
        _formFieldKey.currentState?.validate();
      }
    });
  }

  TextInputType _getKeyboardType() {
    switch (widget.question.textType) {
      case FreeTextQuestionType.numeric:
        return TextInputType.number;
      case FreeTextQuestionType.any:
      case FreeTextQuestionType.alphanumeric:
      case FreeTextQuestionType.custom:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.question.textType) {
      case FreeTextQuestionType.numeric:
        return [FilteringTextInputFormatter.allow(RegExp('^-?[0-9]*'))];
      case FreeTextQuestionType.alphanumeric:
        return [FilteringTextInputFormatter.allow(RegExp(alphanumericPattern))];
      case FreeTextQuestionType.any:
      case FreeTextQuestionType.custom:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final speechSection = _buildSpeechAssistant(theme, loc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: _formFieldKey,
          controller: _textFieldController,
          maxLines: null,
          focusNode: _focusNode,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          textInputAction: TextInputAction.done,
          autovalidateMode: _autovalidateMode,
          onTap: () {
            _handleInteraction();
            _ensureTextFieldVisible();
          },
          onChanged: (value) {
            _handleInteraction();
            _debouncedValidation();
          },
          onFieldSubmitted: (value) {
            _handleSubmit(value);
          },
          validator: (value) {
            final minLength = question.lengthRange.first;

            if (value!.isEmpty && minLength == 0) {
              return null;
            }

            if (value.length < minLength) {
              return AppLocalizations.of(
                context,
              )!.free_text_min_length_error(minLength);
            } else if (value.length > question.lengthRange.last) {
              return AppLocalizations.of(
                context,
              )!.free_text_max_length_error(question.lengthRange.last);
            }

            if (value.isEmpty && minLength == 0) {
              return null;
            }

            switch (question.textType) {
              case FreeTextQuestionType.any:
                return null;
              case FreeTextQuestionType.alphanumeric:
                if (RegExp(alphanumericPattern).hasMatch(value)) {
                  return null;
                } else {
                  return AppLocalizations.of(
                    context,
                  )!.free_text_alphanumeric_error;
                }
              case FreeTextQuestionType.numeric:
                if (RegExp(r'^-?[0-9]+$').hasMatch(value)) {
                  return null;
                } else {
                  return AppLocalizations.of(context)!.free_text_numeric_error;
                }
              case FreeTextQuestionType.custom:
                if (RegExp(question.customTypeExpression!).hasMatch(value)) {
                  return null;
                } else {
                  return AppLocalizations.of(
                    context,
                  )!.free_text_custom_error(question.customTypeExpression!);
                }
            }
          },
        ),
        const SizedBox(height: 16),
        if (speechSection is SizedBox)
          speechSection
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: speechSection,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: _handleSubmit, child: Text(loc.submit)),
          ],
        ),
      ],
    );
  }
}
