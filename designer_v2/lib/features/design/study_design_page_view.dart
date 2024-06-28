import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

abstract class StudyDesignPageWidget extends StudyPageWidget {
  const StudyDesignPageWidget(super.studyCreationArgs, {super.key});

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(studyFormViewModelProvider(studyCreationArgs));

    if (viewModel.isStudyReadonly) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: viewModel.studyType == StudyType.template
                      ? tr.banner_template_readonly_title
                      : tr.banner_study_readonly_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextParagraph(
              text: viewModel.studyType == StudyType.template
                      ? tr.banner_template_readonly_description
                      : tr.banner_study_readonly_description,
            ),
          ],
        ),
        style: BannerStyle.info,
      );
    }

    return null;
  }
}
