import 'package:flutter/material.dart';
import 'package:studyou_core/core.dart';

import '../../../widgets/study_tile.dart';
import 'generic_section.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(UserStudy instance, {GestureTapCallback onTap}) : super(instance, onTap: onTap);

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          StudyTile(
            title: study.study.title,
            description: study.study.description,
            iconName: study.study.iconName,
            contentPadding: EdgeInsets.all(0),
          ),
        ],
      );
}
