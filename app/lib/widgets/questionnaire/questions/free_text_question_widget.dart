import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/speech/speech_to_text_controller.dart';
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
  bool _listeningRequested = false;
  SpeechErrorType? _lastSpeechErrorType;
  String _preSpeechText = '';
  int _insertionIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_speechController == null &&
        SpeechToTextController.isSupportedPlatform) {
      _createSpeechController();
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

  void _createSpeechController() {
    _speechController?.removeListener(_onSpeechStateChanged);
    _speechController?.dispose();
    _speechController = SpeechToTextController(
      onFinalTranscription: _insertSpeechTranscript,
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

    final hasError = state.error != null;
    if (hasError && _listeningRequested) {
      _setListeningRequested(false);
    }

    // Handle partial transcript
    if (state.status == SpeechLifecycleStatus.listening &&
        state.partialTranscript != null) {
      _updateTextWithTranscript(state.partialTranscript!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _updateTextWithTranscript(String transcript) {
    if (transcript.isEmpty) return;
    final controller = _textFieldController;

    // Ensure we have valid state to insert into
    if (_insertionIndex > _preSpeechText.length) {
      _insertionIndex = _preSpeechText.length;
    }

    final previousChar = _insertionIndex > 0
        ? _preSpeechText.substring(_insertionIndex - 1, _insertionIndex)
        : '';
    final needsSpace = previousChar.trim().isNotEmpty;
    final insertion = '${needsSpace ? ' ' : ''}$transcript';

    final newText = _preSpeechText.replaceRange(
      _insertionIndex,
      _insertionIndex,
      insertion,
    );

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _insertionIndex + insertion.length,
      ),
    );
    _handleInteraction();
    _debouncedValidation();
  }

  void _insertSpeechTranscript(String transcript) {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) return;

    _updateTextWithTranscript(trimmed);

    // Update state for next phrase (continuous listening)
    _preSpeechText = _textFieldController.text;
    _insertionIndex = _textFieldController.selection.isValid
        ? _textFieldController.selection.extentOffset
        : _textFieldController.text.length;
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
      _captureCurrentTextState();
      unawaited(_startListeningIfRequested());
    }
  }

  void _captureCurrentTextState() {
    final controller = _textFieldController;
    _preSpeechText = controller.text;
    _insertionIndex = controller.selection.isValid
        ? controller.selection.extentOffset
        : controller.text.length;
  }

  void _stopListeningIntent() {
    _setListeningRequested(false);
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
        status == SpeechLifecycleStatus.idle ||
        status == SpeechLifecycleStatus.ready;
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

  Widget _buildMicButton(ThemeData theme, bool isListening, bool isPreparing) {
    return IconButton.filledTonal(
      onPressed: isPreparing ? null : _toggleSpeechListening,
      icon: isListening
          ? const Icon(Icons.stop_circle_outlined)
          : const Icon(Icons.mic),
      style: IconButton.styleFrom(
        backgroundColor: isListening ? theme.colorScheme.errorContainer : null,
        foregroundColor: isListening
            ? theme.colorScheme.onErrorContainer
            : null,
      ),
      tooltip: isListening ? 'Stop listening' : 'Start listening',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: _formFieldKey,
          controller: _textFieldController,
          maxLines: null,
          minLines: 4,
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
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            hintText: loc.free_text_answer_hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (SpeechToTextController.isSupportedPlatform &&
                _speechController != null)
              ValueListenableBuilder<SpeechControllerState>(
                valueListenable: _speechController!,
                builder: (context, state, _) {
                  if (state.status == SpeechLifecycleStatus.unavailable) {
                    return const SizedBox.shrink();
                  }
                  return _buildMicButton(
                    theme,
                    state.status == SpeechLifecycleStatus.listening,
                    state.status == SpeechLifecycleStatus.preparing,
                  );
                },
              ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _handleSubmit, child: Text(loc.submit)),
          ],
        ),
      ],
    );
  }
}
