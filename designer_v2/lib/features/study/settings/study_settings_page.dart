import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/under_construction.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudySettingsPage extends StudyPageWidget {
  const StudySettingsPage(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText("Study Settings".hardcoded,
            style: Theme.of(context).textTheme.headline5),
        const UnderConstruction(),
      ],
    );
  }
}
