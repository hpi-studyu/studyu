import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

abstract class StudyDesignPageWidget extends StudyPageWidget {
  const StudyDesignPageWidget(super.studyId, {super.key});

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(studyFormViewModelProvider(studyId));

    if (viewModel.isStudyReadonly) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: "This study cannot be edited.".hardcoded,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextParagraph(
                text: "You can only make changes to studies where you are an "
                    "owner or collaborator. Studies that have been launched "
                    "cannot be changed by anyone.".hardcoded
            ),
          ]
        ),
        style: BannerStyle.warning
      );
    }

    return null;
  }
}
