import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/badge.dart';
import 'package:studyu_designer_v2/domain/participation.dart';

class StudyParticipationBadge extends StatelessWidget {
  const StudyParticipationBadge(
      {required this.participation,
        this.type = BadgeType.plain,
        this.showPrefixIcon = true,
        Key? key})
      : super(key: key);

  final Participation participation;
  final BadgeType type;
  final bool showPrefixIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tooltipMessage = (participation.description ?? '').trim();

    Widget inTooltip(Widget child) {
      if (tooltipMessage.isNotEmpty) {
        return Tooltip(
          message: tooltipMessage,
          child: child,
        );
      }
      return child;
    }

    switch (participation) {
      case Participation.open:
        return inTooltip(Badge(
          label: participation.whoShort,
          color: colorScheme.primary.withOpacity(0.8),
          type: type,
          icon: showPrefixIcon ? Icons.people_rounded : null,
        ));
      case Participation.invite:
        return inTooltip(Badge(
          label: participation.whoShort,
          color: colorScheme.onPrimaryContainer.withOpacity(0.6),
          type: type,
          icon: showPrefixIcon ? Icons.lock_rounded : null,
        ));
        return const SizedBox.shrink();
    }
  }
}