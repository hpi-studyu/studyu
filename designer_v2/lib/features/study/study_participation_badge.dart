import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as studybadge;
import 'package:studyu_designer_v2/domain/participation.dart';

class StudyParticipationBadge extends StatelessWidget {
  const StudyParticipationBadge(
      {required this.participation,
      this.type = studybadge.BadgeType.plain,
      this.showPrefixIcon = true,
      this.center = true,
      super.key});

  final Participation participation;
  final studybadge.BadgeType type;
  final bool showPrefixIcon;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tooltipMessage = participation.description;

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
        return inTooltip(studybadge.Badge(
            label: participation.whoShort,
            center: center,
            color: colorScheme.primary.withOpacity(0.8),
            type: type,
            icon: showPrefixIcon ? Icons.people_rounded : null,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0)));
      case Participation.invite:
        return inTooltip(studybadge.Badge(
          label: participation.whoShort,
          center: center,
          color: colorScheme.onPrimaryContainer.withOpacity(0.6),
          type: type,
          icon: showPrefixIcon ? Icons.lock_rounded : null,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        ));
      case Participation.closed:
        return inTooltip(studybadge.Badge(
          label: participation.whoShort,
          center: center,
          color: colorScheme.onPrimaryContainer.withOpacity(0.6),
          type: type,
          icon: showPrefixIcon ? Icons.lock_rounded : null,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        ));
    }
  }
}
