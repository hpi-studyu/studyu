import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/reusable_banner.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyScheduleBanner extends StatelessWidget {
  const StudyScheduleBanner({
    this.isDismissed = false,
    this.onDismissed,
    super.key,
  });

  final bool isDismissed;
  final Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    return ReusableBanner(
      isDismissed: isDismissed,
      onDismissed: onDismissed,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(tr.study_schedule_banner_explanation),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
