import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/theme.dart';

class DateQuestionFormView extends ConsumerWidget {
  const DateQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextParagraph(
          text: "The user will be asked to select a date.",
          style: ThemeConfig.bodyTextMuted(theme),
        ),
      ],
    );
  }
}
