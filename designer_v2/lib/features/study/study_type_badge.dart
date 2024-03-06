import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as studybadge;

class StudyTypeBadge extends StatelessWidget {
  const StudyTypeBadge({required this.studyType, this.type = studybadge.BadgeType.plain, super.key});

  final StudyType? studyType;
  final studybadge.BadgeType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (studyType) {
      case StudyType.standalone:
        return studybadge.Badge(
          label: "Standalone",
          padding: const EdgeInsets.all(0),
          color: colorScheme.secondary.withOpacity(0.85),
          icon: null,
          type: type,
        );
      case StudyType.template:
        return studybadge.Badge(
          label: "Template",
          padding: const EdgeInsets.all(0),
          color: colorScheme.secondary.withOpacity(0.85),
          icon: null,
          type: type,
        );
      case StudyType.subStudy:
        return studybadge.Badge(
          label: "Subtrial",
          padding: const EdgeInsets.all(0),
          color: colorScheme.secondary.withOpacity(0.85),
          icon: null,
          type: type,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
