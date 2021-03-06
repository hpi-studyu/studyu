import 'package:flutter/material.dart';
import 'package:studyou_core/models/study/studies.dart';

import '../../../widgets/study_tile.dart';
import 'generic_section.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(ParseUserStudy instance, {GestureTapCallback onTap}) : super(instance, onTap: onTap);

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          StudyTile(
            title: study.title,
            description: study.description,
            iconName: study.iconName,
            contentPadding: EdgeInsets.all(0),
          ),
        ],
      );
}
