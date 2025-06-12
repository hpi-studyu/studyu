import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class PainQuestionFormView extends ConsumerWidget {
  const PainQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: tr.question_type_pain_description,
        ),
        const SizedBox(height: 24),
        Text(
          tr.question_type_pain_preview_title,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextParagraph(
          text: tr.question_type_pain_preview_description,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 24),
        Text(
          tr.question_type_pain_functionality_title,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextParagraph(
          text: tr.question_type_pain_functionality_description,
        ),
      ],
    );
  }
}
