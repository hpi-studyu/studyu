import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as study_badge;
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';

class ReportBadge extends StatelessWidget {
  const ReportBadge(
      {required this.status,
      this.type = study_badge.BadgeType.outlineFill,
      this.showPrefixIcon = true,
      this.showTooltip = true,
      super.key});

  final ReportStatus? status;
  final study_badge.BadgeType type;
  final bool showPrefixIcon;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prefixIcon = showPrefixIcon ? Icons.circle_rounded : null;

    final tooltipMessage = (status?.description ?? '').trim();

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
      case ReportStatus.primary:
        return inTooltip(study_badge.Badge(
          label: status!.string,
          color: colorScheme.primary,
          type: study_badge.BadgeType.outlineFill,
          icon: prefixIcon,
        ));
      case ReportStatus.secondary:
        return inTooltip(study_badge.Badge(
          label: status!.string,
          color: colorScheme.secondary.withOpacity(0.75),
          type: study_badge.BadgeType.outlineFill,
          icon: prefixIcon,
        ));
      default:
        return const SizedBox.shrink();
    }
  }
}
