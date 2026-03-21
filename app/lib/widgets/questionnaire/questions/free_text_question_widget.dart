import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_regex_validation.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;
  final Function()? onInvalid;

  const FreeTextQuestionWidget({
    super.key,
    required this.question,
    this.onDone,
    this.onInvalid,
  });

  @override
  State<FreeTextQuestionWidget> createState() => _FreeTextQuestionWidgetState();
}

class _FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final _textFieldController = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();
  bool _hadValidSubmission = false;
  Timer? _debounceTimer;

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

  void _validateAndSubmit(String value) {
    if (_formFieldKey.currentState?.validate() == true) {
      widget.onDone?.call(widget.question.constructAnswer(value));
      _hadValidSubmission = true;
    } else if (_hadValidSubmission) {
      widget.onInvalid?.call();
      _hadValidSubmission = false;
    }
  }

  void _debouncedValidateAndSubmit() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _validateAndSubmit(_textFieldController.text);
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
        return [FilteringTextInputFormatter.allow(RegExp('[0-9-]'))];
      case FreeTextQuestionType.any:
      case FreeTextQuestionType.alphanumeric:
      case FreeTextQuestionType.custom:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    return TextFormField(
      key: _formFieldKey,
      controller: _textFieldController,
      maxLines: null,
      focusNode: _focusNode,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        _debouncedValidateAndSubmit();
      },
      validator: (value) {
        final minLength = question.lengthRange.first;
        final customTypeExpression = question.customTypeExpression;

        if (question.textType == FreeTextQuestionType.custom &&
            buildFullMatchRegex(customTypeExpression) == null) {
          return question.customTypeErrorMessage ??
              AppLocalizations.of(context)!.free_text_custom_error;
        }

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
            if (isValidCustomFreeTextInput(value, customTypeExpression)) {
              return null;
            } else {
              return question.customTypeErrorMessage ??
                  AppLocalizations.of(context)!.free_text_custom_error;
            }
        }
      },
    );
  }
}
