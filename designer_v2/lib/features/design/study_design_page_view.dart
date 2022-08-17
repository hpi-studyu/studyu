import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

abstract class StudyDesignPageWidget extends StudyPageWidget {
  const StudyDesignPageWidget(super.studyId, {super.key});

  @override
  Widget? banner(BuildContext context) {
    return BannerBox(text: "Banner text".hardcoded, style: BannerStyle.warning);
  }
}
