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
      // If the restored value is invalid (e.g. after switching question trees
      // and back), surface the error immediately instead of hiding it until
      // the next keystroke.
      if (widget.question.validateResponse(initialValue) != null) {
        _hasInteracted = true;
        _autovalidateMode = AutovalidateMode.always;
      }
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final keyContext = _formFieldKey.currentContext;
    if (keyContext == null || !keyContext.mounted) return;

    Scrollable.ensureVisible(
      keyContext,
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      alignment: 0.5,
    );
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

  /// No input formatters. Let the validator provide error feedback when the
  /// user types characters outside the expected charset, rather than silently
  /// blocking them.
  List<TextInputFormatter> _getInputFormatters() => [];

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final l10n = AppLocalizations.of(context)!;
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
          decoration: InputDecoration(hintText: l10n.free_text_hint),
          onTap: () {
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
