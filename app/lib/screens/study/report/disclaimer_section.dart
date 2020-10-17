import 'package:flutter/material.dart';
import 'package:studyou_core/models/study/studies.dart';

import '../../../util/localization.dart';
import 'generic_section.dart';

class DisclaimerSection extends GenericSection {
  const DisclaimerSection(ParseUserStudy instance, {Function onTap}) : super(instance, onTap: onTap);

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          Text(Nof1Localizations.of(context).translate('report_disclaimer')),
        ],
      );
}
