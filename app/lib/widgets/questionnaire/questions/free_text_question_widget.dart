import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
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
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
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
    );
  }
}
