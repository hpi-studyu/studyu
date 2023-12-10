import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;
  final GlobalKey<FormState> formKey;

  const FreeTextQuestionWidget({super.key, required this.question, this.onDone, required this.formKey});

  @override
  State<FreeTextQuestionWidget> createState() => _FreeTextQuestionWidgetState();
}

class _FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    return Form(
        key: widget.formKey,
        child: TextFormField(
          controller: textFieldController,
          onChanged: (value) {
            if (widget.formKey.currentState!.validate()) {
              setState(() {
                widget.onDone!(widget.question.constructAnswer(value));
              });
            }
          },
          validator: (value) {
            if (value!.length < question.lengthRange.first) {
              return AppLocalizations.of(context)!.free_text_min_length_error(question.lengthRange.first);
            } else if (value.length > question.lengthRange.last) {
              return AppLocalizations.of(context)!.free_text_max_length_error(question.lengthRange.last);
            }
            switch (question.textType) {
              case FreeTextQuestionType.any:
                return null;
              case FreeTextQuestionType.alphanumeric:
                if (RegExp(alphanumericPattern).hasMatch(value)) {
                  return null;
                } else {
                  return AppLocalizations.of(context)!.free_text_alphanumeric_error;
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
                  return AppLocalizations.of(context)!.free_text_custom_error(question.customTypeExpression!);
                }
            }
          },
        ));
  }
}
