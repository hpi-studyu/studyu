import 'package:flutter/material.dart';
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
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _handleAnswerChange(String value) {
    if (_formFieldKey.currentState!.validate()) {
      setState(() {
        widget.onDone!(widget.question.constructAnswer(value));
      });
    }
  }

  void _handleInteraction() {
    if (!_hasInteracted) {
      _hasInteracted = true;
    }
  }

  void _handleSkip() {
    _handleAnswerChange("");
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
          onTap: _handleInteraction,
          onChanged: (value) {
            _hasInteracted = true;
            _handleAnswerChange(value);
          },
          validator: (value) {
            if (value!.length < question.lengthRange.first) {
              return AppLocalizations.of(
                context,
              )!.free_text_min_length_error(question.lengthRange.first);
            } else if (value.length > question.lengthRange.last) {
              return AppLocalizations.of(
                context,
              )!.free_text_max_length_error(question.lengthRange.last);
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
        if (question.lengthRange[0] == 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _handleSkip,
                child: Text(
                  AppLocalizations.of(context)!.next,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
