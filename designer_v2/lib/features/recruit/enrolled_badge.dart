import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/badge.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';

class EnrolledBadge extends StatelessWidget {
  const EnrolledBadge({
    required this.enrolledCount,
    Key? key,
  }) : super(key: key);

  final int enrolledCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedTextStyle = ThemeConfig.bodyTextMuted(theme);

    if (enrolledCount == 0) {
      return Tooltip(
        message:
            "Nobody has enrolled in the study with this code yet".hardcoded,
        child: Badge(
          icon: null,
          label: "-",
          color: mutedTextStyle.color,
        ),
      );
    }

    return Tooltip(
        message: (enrolledCount == 1)
            ? "$enrolledCount participant is enrolled in the study with this code"
            .hardcoded
            : "$enrolledCount participants are enrolled in the study with this code"
            .hardcoded,
        child: Badge(
          icon: Icons.check_circle_rounded,
          iconSize: theme.iconTheme.size,
          label: (enrolledCount > 1) ? enrolledCount.toString() : "",
          color: Colors.green,
          labelStyle: TextStyle(fontSize: mutedTextStyle.fontSize! - 2),
        ));
  }
}
