import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as studybadge;
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class EnrolledBadge extends StatelessWidget {
  const EnrolledBadge({
    required this.enrolledCount,
    super.key,
  });

  final int enrolledCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedTextStyle = ThemeConfig.bodyTextMuted(theme);

    if (enrolledCount == 0) {
      return Tooltip(
        message: tr.enrolled_count_tooltip(enrolledCount),
        child: studybadge.Badge(
          icon: null,
          label: "-",
          color: mutedTextStyle.color,
        ),
      );
    }

    return Tooltip(
        message: tr.enrolled_count_tooltip(enrolledCount),
        child: studybadge.Badge(
          icon: Icons.check_circle_rounded,
          iconSize: theme.iconTheme.size,
          label: (enrolledCount > 1) ? enrolledCount.toString() : "",
          color: Colors.green,
          labelStyle: TextStyle(fontSize: mutedTextStyle.fontSize! - 2),
        ));
  }
}
