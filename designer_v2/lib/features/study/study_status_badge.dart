import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as studybadge;
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/domain/study.dart';

abstract class IStudyStatusBadgeViewModel {
  Participation? get studyParticipation;
  StudyStatus? get studyStatus;
}

class StudyStatusBadge extends StatelessWidget {
  const StudyStatusBadge(
      {required this.status,
      this.participation,
      this.type = studybadge.BadgeType.outlineFill,
      this.showPrefixIcon = true,
      this.showTooltip = true,
      super.key});

  final Participation? participation;
  final StudyStatus? status;
  final studybadge.BadgeType type;
  final bool showPrefixIcon;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prefixIcon = showPrefixIcon ? Icons.circle_rounded : null;

    final tooltipMessage = ('${status?.description ?? ''}\n${participation?.description ?? ''}').trim();

    Widget inTooltip(Widget child) {
      if (tooltipMessage.isNotEmpty && showTooltip) {
        return Tooltip(
          message: tooltipMessage,
          child: child,
        );
      }
      return child;
    }

    switch (status) {
      case StudyStatus.draft:
        return inTooltip(studybadge.Badge(
          label: status!.string,
          color: colorScheme.secondary.withOpacity(0.75),
          type: type,
          icon: prefixIcon,
        ));
      case StudyStatus.closed:
        return inTooltip(studybadge.Badge(
          label: status!.string,
          color: colorScheme.primaryContainer,
          type: type,
          icon: prefixIcon,
        ));
      case StudyStatus.running:
        return inTooltip(studybadge.Badge(
          label: status!.string,
          color: Colors.green,
          type: type,
          icon: prefixIcon,
        ));
      default:
        return const SizedBox.shrink();
    }
  }
}
