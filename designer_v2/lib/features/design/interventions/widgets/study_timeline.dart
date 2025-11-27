import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';

class StudyTimeline extends StatelessWidget {
  final StudyScheduleControls formViewModel;

  const StudyTimeline({required this.formViewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = formViewModel.segments;

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    int currentDay = 0;
    final List<Widget> dayLabels = [
      const Text("Day 0", style: TextStyle(color: Colors.grey, fontSize: 12)),
    ];

    for (final segment in segments) {
      final duration = segment.getDuration(formViewModel.interventions);
      final flex = duration > 0 ? duration : 1;
      currentDay += duration;
      dayLabels.add(
        Expanded(
          flex: flex,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Day $currentDay",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Study Timeline", // todo localize
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Row(
                children: segments.map((segment) {
                  final duration = segment.getDuration(
                    formViewModel.interventions,
                  );
                  final flex = duration > 0 ? duration : 1;
                  final color = _getSegmentColor(segment.type);

                  // Show detailed sub-segments for alternating and counter-balanced
                  if (segment is AlternatingScheduleSegment ||
                      segment is CounterBalancedScheduleSegment) {
                    return Expanded(
                      flex: flex,
                      child: _buildDetailedSegment(
                        segment,
                        formViewModel,
                        color,
                      ),
                    );
                  }

                  return Expanded(
                    flex: flex,
                    child: Tooltip(
                      message: _getTooltipMessage(
                        segment,
                        formViewModel.interventions,
                      ),
                      child: Container(
                        color: color,
                        alignment: Alignment.center,
                        child: Text(
                          _getTimelineLabel(segment),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: dayLabels),
        ],
      ),
    );
  }

  String _getTooltipMessage(
    StudyScheduleSegment segment,
    List<Intervention> interventions,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(segment.name);
    final totalDuration = segment.getDuration(interventions);
    buffer.writeln('Total Duration: $totalDuration days\n');

    if (segment is AlternatingScheduleSegment) {
      final selectedIds = segment.interventionIds;
      final useCustomIds = selectedIds != null && selectedIds.isNotEmpty;
      final count = useCustomIds ? selectedIds.length : interventions.length;

      buffer.writeln('Alternating Schedule:');
      buffer.writeln('• ${segment.interventionDuration} days per intervention');
      buffer.writeln('• ${segment.cycleAmount} cycle(s)');
      buffer.writeln('• $count intervention(s) in rotation\n');

      buffer.writeln('Time Allocation per Intervention:');
      final timePerIntervention =
          segment.interventionDuration * segment.cycleAmount;

      for (var i = 0; i < count; i++) {
        final label = 'Position ${String.fromCharCode(65 + i)}';
        buffer.writeln('  $label: $timePerIntervention days');
      }

      buffer.write(
        '\nCalculation: ${segment.interventionDuration} days × ${segment.cycleAmount} cycle(s) × $count intervention(s) = $totalDuration days',
      );
    } else if (segment is CounterBalancedScheduleSegment) {
      final selectedIds = segment.interventionIds;
      final useCustomIds = selectedIds != null && selectedIds.isNotEmpty;
      final count = useCustomIds ? selectedIds.length : interventions.length;

      buffer.writeln('Counter-Balanced Schedule:');
      buffer.writeln('• ${segment.interventionDuration} days per intervention');
      buffer.writeln('• ${segment.cycleAmount} cycle(s)');
      buffer.writeln('• $count intervention(s) in rotation');
      buffer.writeln('• Order randomized each cycle\n');

      buffer.writeln('Time Allocation per Intervention:');
      final timePerIntervention =
          segment.interventionDuration * segment.cycleAmount;

      for (var i = 0; i < count; i++) {
        final label = 'Position ${String.fromCharCode(65 + i)}';
        buffer.writeln('  $label: $timePerIntervention days');
      }

      buffer.write(
        '\nCalculation: ${segment.interventionDuration} days × ${segment.cycleAmount} cycle(s) × $count intervention(s) = $totalDuration days',
      );
    } else if (segment is ThompsonSamplingScheduleSegment) {
      buffer.writeln('Thompson Sampling:');
      buffer.writeln('• ${segment.interventionDuration} days per draw');
      buffer.writeln('• ${segment.interventionDrawAmount} draw(s)');
      buffer.write(
        '\nCalculation: ${segment.interventionDuration} days × ${segment.interventionDrawAmount} draw(s) = $totalDuration days',
      );
    } else if (segment is SingleInterventionScheduleSegment) {
      buffer.write('Duration: ${segment.duration} days');
    } else if (segment is BaselineScheduleSegment) {
      buffer.write('Baseline period: $totalDuration days');
    }

    return buffer.toString();
  }

  String _getTimelineLabel(StudyScheduleSegment segment) {
    if (segment is SingleInterventionScheduleSegment) {
      return String.fromCharCode(65 + segment.interventionIndex);
    }
    return segment.name;
  }

  Widget _buildDetailedSegment(
    StudyScheduleSegment segment,
    StudyScheduleControls formViewModel,
    Color baseColor,
  ) {
    List<String>? interventionIds;
    int interventionDuration = 0;
    int cycleAmount = 0;
    bool isCounterBalanced = false;

    if (segment is AlternatingScheduleSegment) {
      interventionIds = segment.interventionIds;
      interventionDuration = segment.interventionDuration;
      cycleAmount = segment.cycleAmount;
      isCounterBalanced = false;
    } else if (segment is CounterBalancedScheduleSegment) {
      interventionIds = segment.interventionIds;
      interventionDuration = segment.interventionDuration;
      cycleAmount = segment.cycleAmount;
      isCounterBalanced = true;
    }

    final useCustomIds = interventionIds != null && interventionIds.isNotEmpty;
    final count = useCustomIds
        ? interventionIds.length
        : formViewModel.interventions.length;

    final List<Widget> bars = [];
    final baseHSL = HSLColor.fromColor(baseColor);

    // Generate colors for all interventions (not just 2)
    final interventionColors = <Color>[];
    for (var i = 0; i < count; i++) {
      // Distribute lightness variations evenly across interventions
      final lightnessAdjustment = (i - (count - 1) / 2) * 0.05;
      final color = baseHSL
          .withLightness(
            (baseHSL.lightness + lightnessAdjustment).clamp(0.0, 1.0),
          )
          .toColor();
      interventionColors.add(color);
    }

    if (isCounterBalanced) {
      // Counter-Balanced: Random order each cycle (show with visual indication)
      for (var cycle = 0; cycle < cycleAmount; cycle++) {
        for (var i = 0; i < count; i++) {
          // For visualization, show the pattern with rotation
          final indexInSequence = (i + cycle) % count;
          final label = String.fromCharCode(65 + indexInSequence);
          final interventionColor = interventionColors[indexInSequence];

          bars.add(
            Expanded(
              flex: interventionDuration,
              child: Tooltip(
                message: _getTooltipMessage(
                  segment,
                  formViewModel.interventions,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: interventionColor,
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      // Alternating: Fixed order ABC... each cycle
      for (var cycle = 0; cycle < cycleAmount; cycle++) {
        for (var i = 0; i < count; i++) {
          final label = String.fromCharCode(65 + i);
          final interventionColor = interventionColors[i];

          bars.add(
            Expanded(
              flex: interventionDuration,
              child: Tooltip(
                message: _getTooltipMessage(
                  segment,
                  formViewModel.interventions,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: interventionColor,
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Row(children: bars);
  }

  Color _getSegmentColor(StudyScheduleSegmentType type) {
    switch (type) {
      case StudyScheduleSegmentType.baseline:
        return const Color(0xFF3B82F6); // Blue
      case StudyScheduleSegmentType.alternating:
        return const Color(0xFF10B981); // Green
      case StudyScheduleSegmentType.counterBalanced:
        return const Color(0xFF8B5CF6); // Purple
      case StudyScheduleSegmentType.thompsonSampling:
        return const Color(0xFFF59E0B); // Orange
      case StudyScheduleSegmentType.singleIntervention:
        return const Color(0xFFEC4899); // Pink
    }
  }
}
