import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import '../../../widgets/study_tile.dart';
import 'generic_section.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(StudySubject? subject, {Key? key, GestureTapCallback? onTap})
      : super(subject, key: key, onTap: onTap);

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
