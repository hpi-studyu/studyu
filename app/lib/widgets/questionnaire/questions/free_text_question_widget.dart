import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;
  final Function()? onInvalid;
  final bool isLastQuestion;
  final bool hasConditionalDependents;
  final Answer<String>? initialAnswer;

  const FreeTextQuestionWidget({
    super.key,
    required this.question,
    this.onDone,
    this.onInvalid,
    this.isLastQuestion = true,
    this.hasConditionalDependents = false,
    this.initialAnswer,
  });

  @override
  State<FreeTextQuestionWidget> createState() => FreeTextQuestionWidgetState();
}

class FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final _textFieldController = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();
  bool _hasInteracted = false;
  bool _hasSubmitted = false;
  bool _hasPendingNonLastChange = false;
  bool _reactiveValidationArmed = false;
  bool _requiresExplicitSubmit = false;
  String? _lastSubmittedValue;
  Timer? _debounceTimer;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialAnswer?.response;
    if (initialValue != null) {
      _textFieldController.text = initialValue;
      _hasSubmitted = true;
      _reactiveValidationArmed = true;
      _lastSubmittedValue = initialValue;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _ensureTextFieldVisible();
    } else {
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
        alignment: 0.5,
      );
    }
  }

  void _handleAutoSubmit() {
    if (widget.isLastQuestion &&
        _hasInteracted &&
        !_hasSubmitted &&
        !_requiresExplicitSubmit) {
      _handleSubmit();
    }
    // Do not reset submitted state on blur — a valid answer remains valid
    // even after focus changes.
  }

  void _handleSubmit([String? value]) {
    _debounceTimer?.cancel();
    FocusScope.of(context).unfocus();
    final text = value ?? _textFieldController.text;
    _validateAndSubmit(text, forceSubmit: true);
  }

  void _validateAndSubmit(String value, {bool forceSubmit = false}) {
    if (_formFieldKey.currentState?.validate() == true) {
      if (_hasSubmitted &&
          value != _lastSubmittedValue &&
          !widget.isLastQuestion) {
        if (widget.hasConditionalDependents) {
          if (!_hasPendingNonLastChange) {
            widget.onInvalid?.call();
          }
          _hasSubmitted = false;
          _hasPendingNonLastChange = true;
          _requiresExplicitSubmit = true;
        } else {
          // Non-conditional non-last edit: sync via onDone, keep later
          // questions visible, Submit stays hidden.
          widget.onDone?.call(widget.question.constructAnswer(value));
          _hasSubmitted = true;
          _hasPendingNonLastChange = false;
          _reactiveValidationArmed = true;
          _lastSubmittedValue = value;
        }
        return;
      }

      // Non-conditional, not-yet-submitted after invalidation: sync corrected
      // valid value via onDone. Required so Complete sync can find the answer.
      if (!_hasSubmitted &&
          !widget.isLastQuestion &&
          !widget.hasConditionalDependents) {
        widget.onDone?.call(widget.question.constructAnswer(value));
        _hasSubmitted = true;
        _reactiveValidationArmed = true;
        _lastSubmittedValue = value;
        return;
      }

      if (widget.isLastQuestion && (forceSubmit || !_requiresExplicitSubmit)) {
        widget.onDone?.call(widget.question.constructAnswer(value));
        _hasSubmitted = true;
        _hasPendingNonLastChange = false;
        _reactiveValidationArmed = true;
        _requiresExplicitSubmit = false;
        _lastSubmittedValue = value;
      }
    } else if (_hasSubmitted) {
      widget.onInvalid?.call();
      _hasSubmitted = false;
      _hasPendingNonLastChange = false;
      _requiresExplicitSubmit = !widget.isLastQuestion;
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
      if (mounted && _reactiveValidationArmed) {
        _validateAndSubmit(_textFieldController.text);
      }
    });
  }

  bool validateForComplete() {
    _debounceTimer?.cancel();
    final isValid = _formFieldKey.currentState?.validate() == true;
    setState(() {
      _hasInteracted = true;
      _autovalidateMode = AutovalidateMode.always;
    });
    return isValid;
  }

  Answer<String> buildAnswerForComplete() {
    return widget.question.constructAnswer(_textFieldController.text);
  }

  void markSyncedForComplete() {
    final value = _textFieldController.text;
    _hasSubmitted = true;
    _hasPendingNonLastChange = false;
    _reactiveValidationArmed = true;
    _requiresExplicitSubmit = false;
    _lastSubmittedValue = value;
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
            final input = value ?? '';
            final minLength = question.lengthRange.first;

            if (question.textType != FreeTextQuestionType.custom) {
              if (input.isEmpty && minLength == 0) {
                return null;
              }

              if (input.length < minLength) {
                return AppLocalizations.of(
                  context,
                )!.free_text_min_length_error(minLength);
              } else if (input.length > question.lengthRange.last) {
                return AppLocalizations.of(
                  context,
                )!.free_text_max_length_error(question.lengthRange.last);
              }
            }

            switch (question.textType) {
              case FreeTextQuestionType.any:
                return null;
              case FreeTextQuestionType.alphanumeric:
                if (RegExp(alphanumericPattern).hasMatch(input)) {
                  return null;
                } else {
                  return AppLocalizations.of(
                    context,
                  )!.free_text_alphanumeric_error;
                }
              case FreeTextQuestionType.numeric:
                if (RegExp(r'^-?[0-9]+$').hasMatch(input)) {
                  return null;
                } else {
                  return AppLocalizations.of(context)!.free_text_numeric_error;
                }
              case FreeTextQuestionType.custom:
                final expression = question.customTypeExpression;
                if (expression == null || expression.isEmpty) {
                  return AppLocalizations.of(context)!.free_text_custom_error;
                }
                try {
                  final regex = RegExp('^(?:$expression)\$');
                  if (regex.hasMatch(input)) {
                    return null;
                  }
                } on FormatException catch (error) {
                  if (kDebugMode) {
                    debugPrint(
                      'Invalid custom regex for free text question '
                      '${question.id}: $error',
                    );
                  }
                }
                return AppLocalizations.of(context)!.free_text_custom_error;
            }
          },
        ),
        if (widget.isLastQuestion) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _handleSubmit,
                child: Text(AppLocalizations.of(context)!.submit),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
