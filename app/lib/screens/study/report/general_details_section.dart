import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/report/generic_section.dart';
import 'package:studyu_app/widgets/study_tile.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(super.subject, {super.key, super.onTap});

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          StudyTile(
            studyType: subject!.study.type,
            title: subject!.study.title,
            description: subject!.study.description,
            iconName: subject!.study.iconName,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      );
}
