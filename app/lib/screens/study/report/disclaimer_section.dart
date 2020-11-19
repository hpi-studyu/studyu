import 'package:flutter/material.dart';
import 'package:studyou_core/models/study/studies.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'generic_section.dart';

class DisclaimerSection extends GenericSection {
  const DisclaimerSection(ParseUserStudy instance, {Function onTap}) : super(instance, onTap: onTap);

  @override
  Widget buildContent(BuildContext context) => Column(
        children: [
          Text(AppLocalizations.of(context).report_disclaimer),
        ],
      );
}
