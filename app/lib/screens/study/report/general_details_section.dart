import 'package:flutter/material.dart';

import '../../../widgets/study_tile.dart';
import 'generic_section.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(super.subject, {super.key, super.onTap});

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          StudyTile(
            title: subject!.study.title,
            description: subject!.study.description,
            iconName: subject!.study.iconName,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      );
}
