import 'package:flutter/material.dart';
import 'package:studyu_app/spacing.dart';
import 'package:studyu_app/util/intervention.dart';
import 'package:studyu_core/core.dart';

class ProgressRow extends StatelessWidget {
  final StudySubject? subject;

  const ProgressRow({super.key, this.subject});

  @override
  Widget build(BuildContext context) {
    final currentPhase = subject!.getInterventionIndexForDate(DateTime.now());
    final interventions = subject!.getInterventionsInOrder();
    final phaseDuration = subject!.study.schedule.phaseDuration;
    final phaseDay = DateTime.now()
        .differenceInDays(subject!.startOfPhase(currentPhase))
        .clamp(0, phaseDuration - 1);
    final phaseDayProgress = (phaseDay + 1) / phaseDuration;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StudyUSpacing.space3,
        vertical: StudyUSpacing.space3,
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run, color: Color(0xFF666666), size: 20),
          const SizedBox(width: StudyUSpacing.space1),
          ..._buildNodesAndLines(interventions, currentPhase, phaseDayProgress),
          const SizedBox(width: StudyUSpacing.space1),
          const Icon(Icons.flag, color: Color(0xFF666666), size: 20),
        ],
      ),
    );
  }

  List<Widget> _buildNodesAndLines(
    List<Intervention> interventions,
    int currentPhase,
    double phaseDayProgress,
  ) {
    final List<Widget> widgets = [];
    for (var i = 0; i < interventions.length; i++) {
      final intervention = interventions[i];
      final isCurrent = i == currentPhase;
      final isPast = i < currentPhase;

      widgets.add(
        _TimelineNode(
          intervention: intervention,
          isCurrent: isCurrent,
          isPast: isPast,
          phaseDayProgress: phaseDayProgress,
        ),
      );

      if (i < interventions.length - 1) {
        widgets.add(
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(
                horizontal: StudyUSpacing.space1,
              ),
              color: isCurrent
                  ? const Color(0xFF2196F3)
                  : const Color(0xFFCCCCCC),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _TimelineNode extends StatelessWidget {
  final Intervention intervention;
  final bool isCurrent;
  final bool isPast;
  final double phaseDayProgress;

  const _TimelineNode({
    required this.intervention,
    required this.isCurrent,
    required this.isPast,
    required this.phaseDayProgress,
  });

  static const _activeColor = Color(0xFFFF9800);
  static const _pastColor = Color(0xFF9E9E9E);
  static const _futureColor = Color(0xFFCCCCCC);
  static const _progressColor = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final fillColor = isCurrent
        ? _activeColor
        : (isPast ? _pastColor : _futureColor);
    final node = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: fillColor, shape: BoxShape.circle),
      child: Center(child: interventionIcon(intervention, color: Colors.white)),
    );

    if (!isCurrent) return node;

    return SizedBox.square(
      dimension: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 42,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 3,
              color: _activeColor.withValues(alpha: 0.24),
            ),
          ),
          SizedBox.square(
            dimension: 42,
            child: CircularProgressIndicator(
              value: phaseDayProgress,
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              color: _progressColor,
            ),
          ),
          node,
        ],
      ),
    );
  }
}
