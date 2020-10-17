import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/study/studies.dart';

import 'generic_section.dart';

class GeneralDetailsSection extends GenericSection {
  const GeneralDetailsSection(ParseUserStudy instance, {Function onTap}) : super(instance, onTap: onTap);

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          Text(study.description),
        ],
      );
}
