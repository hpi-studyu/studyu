import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;
  final Answer<String>? initialAnswer;
  final void Function(String questionId, String value)? onDraftChanged;

  const FreeTextQuestionWidget({
    super.key,
    required this.question,
    this.onDone,
    this.initialAnswer,
    this.onDraftChanged,
  });

  @override
  State<FreeTextQuestionWidget> createState() => FreeTextQuestionWidgetState();
}

class FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final _textFieldController = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();
  bool _hasInteracted = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialAnswer?.response;
    if (initialValue != null) {
      _textFieldController.text = initialValue;
      widget.onDraftChanged?.call(widget.question.id, initialValue);
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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

  void _handleInteraction() {
    if (!_hasInteracted) {
      _hasInteracted = true;
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
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
            widget.onDraftChanged?.call(widget.question.id, value);
            _handleInteraction();
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          validator: (value) {
            final error = question.validateResponse(value ?? '');
            return switch (error) {
              FreeTextValidationError.tooShort => AppLocalizations.of(
                context,
              )!.free_text_min_length_error(question.lengthRange.first),
              FreeTextValidationError.tooLong => AppLocalizations.of(
                context,
              )!.free_text_max_length_error(question.lengthRange.last),
              FreeTextValidationError.notAlphanumeric => AppLocalizations.of(
                context,
              )!.free_text_alphanumeric_error,
              FreeTextValidationError.notNumeric => AppLocalizations.of(
                context,
              )!.free_text_numeric_error,
              FreeTextValidationError.customMismatch => AppLocalizations.of(
                context,
              )!.free_text_custom_error,
              FreeTextValidationError.invalidCustomExpression =>
                AppLocalizations.of(context)!.free_text_custom_error,
              null => null,
            };
          },
        ),
      ],
    );
  }
}
