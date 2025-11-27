import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_banner.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class StudyScheduleFormView extends FormConsumerWidget {
  const StudyScheduleFormView({required this.formViewModel, super.key});

  final StudyScheduleControls formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use a responsive constrained box so the form can expand on wider
        // layouts instead of being stuck to a narrow minWidth.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SizedBox(
            width: double.infinity,
            child: ScheduleFormView(formViewModel: formViewModel),
          ),
        ),
      ],
    );
  }
}

class ScheduleFormView extends StatefulWidget {
  const ScheduleFormView({required this.formViewModel, super.key});

  final StudyScheduleControls formViewModel;

  @override
  State<ScheduleFormView> createState() => _ScheduleFormViewState();
}

class _ScheduleFormViewState extends State<ScheduleFormView> {
  final List<StudyScheduleSegmentType> allSegmentTypes =
      StudyScheduleSegmentType.values;

  StudyScheduleSegmentType selectedSegmentType =
      StudyScheduleSegmentType.baseline;
  bool _isBannerDismissed = true;

  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.formViewModel.segmentsControl.valueChanges.listen((
      _,
    ) {
      widget.formViewModel.updateSegmentsFromSegmentsControl();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _studyScheduleDescription(),
        const SizedBox(height: 24.0),
        StudyTimeline(formViewModel: widget.formViewModel),
        const SizedBox(height: 24.0),
        // reduce the horizontal padding so items can use more available width
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          buildDefaultDragHandles: false,
          children: <Widget>[
            for (
              int i = 0;
              i < widget.formViewModel.segmentsControl.controls.length;
              i++
            )
              StudyScheduleSection(
                formViewModel: widget.formViewModel,
                key: ObjectKey(
                  widget.formViewModel.segmentsControl.controls[i],
                ),
                index: i,
                segment: widget.formViewModel.segments[i],
                segmentControl:
                    widget.formViewModel.segmentsControl.controls[i]
                        as FormGroup,
                interventions: widget.formViewModel.interventions,
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final reorderedSegment = widget.formViewModel.segmentsControl
                .removeAt(oldIndex);
            widget.formViewModel.segmentsControl.insert(
              newIndex,
              reorderedSegment,
            );
            widget.formViewModel.updateSegmentsFromSegmentsControl();
          },
        ),
        const SizedBox(height: 24.0),
        AddScheduleBlockButton(
          onPressed: (type) {
            widget.formViewModel.addFormGroupToSegments(
              widget.formViewModel.createFormGroup(type),
            );
          },
        ),
      ],
    );
  }

  Widget _studyScheduleDescription() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(text: tr.study_schedule_banner_description),
        const SizedBox(height: 16.0),
        _buildSequenceTypeInfo(
          theme,
          tr.study_schedule_alternating_description,
        ),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_balanced_description),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_random_description),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_custom_description),
        const SizedBox(height: 8.0),
        Hyperlink(
          icon: Icons.north_east_rounded,
          text: tr.study_schedule_learn_more,
          onClick: () {
            setState(() {
              _isBannerDismissed = false;
            });
          },
          visitedColor: null,
        ),
        const SizedBox(height: 8.0),
        StudyScheduleBanner(
          isDismissed: _isBannerDismissed,
          onDismissed: () {
            setState(() {
              _isBannerDismissed = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSequenceTypeInfo(ThemeData theme, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8.0, right: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(child: TextParagraph(text: description)),
      ],
    );
  }
}

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
                          _getTimelineLabel(
                            segment,
                          ), // Get simplified label for timeline
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
      final selectedIndices = segment.interventionIds;
      final useIndices = selectedIndices != null && selectedIndices.isNotEmpty;
      final count = useIndices ? selectedIndices.length : interventions.length;
      // Maximum 2 interventions (A and B) can be used
      final clampedCount = count > 2 ? 2 : count;

      buffer.writeln('Alternating Schedule:');
      buffer.writeln('• ${segment.interventionDuration} days per intervention');
      buffer.writeln('• ${segment.cycleAmount} cycle(s)');
      buffer.writeln('• $clampedCount intervention(s) in rotation\n');

      buffer.writeln('Time Allocation per Intervention:');
      final timePerIntervention =
          segment.interventionDuration * segment.cycleAmount;

      if (useIndices) {
        // Only show first 2 interventions
        final indicesToShow = selectedIndices.take(2).toList();
        for (final index in indicesToShow) {
          final label = interventions.length == 2
              ? 'Intervention ${String.fromCharCode(65 + index)}'
              : 'Choice ${String.fromCharCode(65 + index)}';
          buffer.writeln('  $label: $timePerIntervention days');
        }
      } else {
        for (var i = 0; i < clampedCount; i++) {
          final label = interventions.length == 2
              ? 'Intervention ${String.fromCharCode(65 + i)}'
              : 'Choice ${String.fromCharCode(65 + i)}';
          buffer.writeln('  $label: $timePerIntervention days');
        }
      }

      buffer.write(
        '\nCalculation: ${segment.interventionDuration} days × ${segment.cycleAmount} cycle(s) × $clampedCount intervention(s) = $totalDuration days',
      );
    } else if (segment is CounterBalancedScheduleSegment) {
      final selectedIndices = segment.interventionIds;
      final useIndices = selectedIndices != null && selectedIndices.isNotEmpty;
      final count = useIndices ? selectedIndices.length : interventions.length;
      // Maximum 2 interventions (A and B) can be used
      final clampedCount = count > 2 ? 2 : count;

      buffer.writeln('Counter-Balanced Schedule:');
      buffer.writeln('• ${segment.interventionDuration} days per intervention');
      buffer.writeln('• ${segment.cycleAmount} cycle(s)');
      buffer.writeln('• $clampedCount intervention(s) in rotation');
      buffer.writeln('• Order rotates each cycle\n');

      buffer.writeln('Time Allocation per Intervention:');
      final timePerIntervention =
          segment.interventionDuration * segment.cycleAmount;

      if (useIndices) {
        // Only show first 2 interventions
        final indicesToShow = selectedIndices.take(2).toList();
        for (final index in indicesToShow) {
          final label = interventions.length == 2
              ? 'Intervention ${String.fromCharCode(65 + index)}'
              : 'Choice ${String.fromCharCode(65 + index)}';
          buffer.writeln('  $label: $timePerIntervention days');
        }
      } else {
        for (var i = 0; i < clampedCount; i++) {
          final label = interventions.length == 2
              ? 'Intervention ${String.fromCharCode(65 + i)}'
              : 'Choice ${String.fromCharCode(65 + i)}';
          buffer.writeln('  $label: $timePerIntervention days');
        }
      }

      buffer.write(
        '\nCalculation: ${segment.interventionDuration} days × ${segment.cycleAmount} cycle(s) × $clampedCount intervention(s) = $totalDuration days',
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
    // For single intervention segments, show just the letter (A or B)
    if (segment is SingleInterventionScheduleSegment) {
      return String.fromCharCode(65 + segment.interventionIndex);
    }
    // For all other segments, use the default name
    return segment.name;
  }

  Widget _buildDetailedSegment(
    StudyScheduleSegment segment,
    StudyScheduleControls formViewModel,
    Color baseColor,
  ) {
    List<int>? selectedIndices;
    int interventionDuration = 0;
    int cycleAmount = 0;
    bool isCounterBalanced = false;

    if (segment is AlternatingScheduleSegment) {
      selectedIndices = segment.interventionIds;
      interventionDuration = segment.interventionDuration;
      cycleAmount = segment.cycleAmount;
      isCounterBalanced = false;
    } else if (segment is CounterBalancedScheduleSegment) {
      selectedIndices = segment.interventionIds;
      interventionDuration = segment.interventionDuration;
      cycleAmount = segment.cycleAmount;
      isCounterBalanced = true;
    }

    final useIndices = selectedIndices != null && selectedIndices.isNotEmpty;
    final count = useIndices
        ? selectedIndices.length
        : formViewModel.interventions.length;
    // Maximum 2 interventions (A and B) can be used
    final clampedCount = count > 2 ? 2 : count;

    // Create pattern visualization with color variations of the segment's base color
    final List<Widget> bars = [];

    // Convert base color to HSL for creating variations
    final baseHSL = HSLColor.fromColor(baseColor);

    // Create subtle color variations for intervention A and B
    // Use smaller lightness differences to keep the segment visually cohesive
    // A is slightly lighter, B is slightly darker
    final colorA = baseHSL
        .withLightness((baseHSL.lightness + 0.05).clamp(0.0, 1.0))
        .toColor();
    final colorB = baseHSL
        .withLightness((baseHSL.lightness - 0.05).clamp(0.0, 1.0))
        .toColor();
    final interventionColors = [colorA, colorB];

    if (isCounterBalanced) {
      // Counter-Balanced: ABBA pattern that rotates each cycle
      // Cycle 0: A-B-B-A, Cycle 1: B-A-A-B, etc.
      for (var cycle = 0; cycle < cycleAmount; cycle++) {
        for (var i = 0; i < clampedCount; i++) {
          // Calculate which intervention to show based on counter-balancing logic
          final indexInSequence = (i + cycle) % clampedCount;
          final interventionIndex = useIndices
              ? selectedIndices[indexInSequence]
              : indexInSequence;

          final label = String.fromCharCode(65 + interventionIndex);
          final interventionColor = interventionColors[interventionIndex % 2];

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
      // Alternating: Simple ABABAB... pattern
      for (var cycle = 0; cycle < cycleAmount; cycle++) {
        for (var i = 0; i < clampedCount; i++) {
          final interventionIndex = useIndices ? selectedIndices[i] : i;
          final label = String.fromCharCode(65 + interventionIndex);
          final interventionColor = interventionColors[interventionIndex % 2];

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

class AddScheduleBlockButton extends StatelessWidget {
  final Function(StudyScheduleSegmentType) onPressed;

  const AddScheduleBlockButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<StudyScheduleSegmentType>(
      onSelected: onPressed,
      itemBuilder: (context) {
        return StudyScheduleSegmentType.values.map((type) {
          return PopupMenuItem(
            value: type,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSegmentColor(type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(type.string),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 6.0),
            Text(
              "Add Schedule Block", // todo localize
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
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

class StudyScheduleSection extends StatefulWidget {
  final int index;
  final StudyScheduleSegment segment;
  final FormGroup segmentControl;
  final List<Intervention> interventions;

  final StudyScheduleControls formViewModel;

  const StudyScheduleSection({
    super.key,
    required this.formViewModel,
    required this.index,
    required this.segment,
    required this.segmentControl,
    required this.interventions,
  });

  @override
  State<StudyScheduleSection> createState() => _StudyScheduleSectionState();
}

class _StudyScheduleSectionState extends State<StudyScheduleSection> {
  bool _isExpanded = false; // Default to collapsed

  String _getSegmentDisplayName() {
    final segment = widget.segment;
    final totalInterventions = widget.formViewModel.interventions.length;

    if (segment is AlternatingScheduleSegment ||
        segment is CounterBalancedScheduleSegment) {
      List<int>? selectedIndices;
      if (segment is AlternatingScheduleSegment) {
        selectedIndices = segment.interventionIds;
      } else if (segment is CounterBalancedScheduleSegment) {
        selectedIndices = segment.interventionIds;
      }

      final useIndices = selectedIndices != null && selectedIndices.isNotEmpty;
      final count = useIndices ? selectedIndices.length : totalInterventions;
      // Maximum 2 interventions (A and B) can be used
      final clampedCount = count > 2 ? 2 : count;

      // Build the intervention pattern string (e.g., "A-B" or "A-B-C")
      final pattern = StringBuffer();
      if (useIndices) {
        // Only show first 2 interventions
        final indicesToShow = selectedIndices.take(2).toList();
        for (var i = 0; i < indicesToShow.length; i++) {
          if (i > 0) pattern.write('-');
          pattern.write(String.fromCharCode(65 + indicesToShow[i]));
        }
      } else {
        for (var i = 0; i < clampedCount; i++) {
          if (i > 0) pattern.write('-');
          pattern.write(String.fromCharCode(65 + i));
        }
      }

      final baseName = segment is AlternatingScheduleSegment
          ? 'Alternating'
          : 'Counter-Balanced';
      return '$baseName ($pattern)';
    }

    // For single intervention segments, show "Single Intervention: Choice X"
    if (segment is SingleInterventionScheduleSegment) {
      final letter = String.fromCharCode(65 + segment.interventionIndex);
      return 'Single Intervention: Choice $letter';
    }

    return segment.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = widget.segment.getDuration(widget.interventions);
    final type = widget.segment.type;
    final color = _getSegmentColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(widget.segmentControl.hashCode),
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                _getSegmentDisplayName(), // Using descriptive name
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Text(
            "Duration: $duration days", // todo localize
            style: ThemeConfig.bodyTextMuted(theme),
          ),
          leading: ReorderableDragStartListener(
            index: widget.index,
            child: Icon(
              Icons.drag_indicator,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed: () {
                  widget.formViewModel.deleteSegment(widget.index);
                },
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  ..._getChildrenBasedOnType(
                    type,
                    widget.segmentControl,
                    widget.formViewModel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  List<Widget> _getChildrenBasedOnType(
    StudyScheduleSegmentType type,
    FormGroup segmentControl,
    StudyScheduleControls formViewModel,
  ) {
    switch (type) {
      case StudyScheduleSegmentType.baseline:
        return _getBaselineControls(segmentControl);
      case StudyScheduleSegmentType.alternating:
        return _getAlternatingControls(segmentControl, formViewModel);
      case StudyScheduleSegmentType.counterBalanced:
        return _getCounterBalancedControls(segmentControl, formViewModel);
      case StudyScheduleSegmentType.thompsonSampling:
        return _getThompsonSamplingControls(segmentControl, formViewModel);
      case StudyScheduleSegmentType.singleIntervention:
        return _getSingleInterventionControls(segmentControl, formViewModel);
    }
  }

  List<Widget> _getBaselineControls(FormGroup segmentControl) {
    return [
      ReactiveTextField(
        formControl:
            segmentControl.control('duration') as FormControl<dynamic>?,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          // todo localize
          labelText: 'Duration (days)',
          helperText:
              ' ', // Reserve space for helper text if needed or just spacing
        ),
        controller: ZeroValueController(),
      ),
    ];
  }

  List<Widget> _getAlternatingControls(
    FormGroup segmentControl,
    StudyScheduleControls formViewModel,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDuration')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Intervention Duration',
              ),
              controller: ZeroValueController(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('cycleAmount')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Cycle Amount',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _getCounterBalancedControls(
    FormGroup segmentControl,
    StudyScheduleControls formViewModel,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDuration')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Intervention Duration',
              ),
              controller: ZeroValueController(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('cycleAmount')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Cycle Amount',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _getThompsonSamplingControls(
    FormGroup segmentControl,
    StudyScheduleControls formViewModel,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDuration')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Intervention Duration',
              ),
              controller: ZeroValueController(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDrawAmount')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Intervention Draw Amount',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      // todo localize
      Builder(
        builder: (context) => Text(
          "Deciding Metric",
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue:
            (segmentControl.control('observationId').value as String).isEmpty
            ? null
            : (segmentControl.control('observationId').value as String),
        items: formViewModel.observations
            .map(
              (observation) => DropdownMenuItem(
                value: observation.id,
                child: Text(observation.title ?? observation.id),
              ),
            )
            .toList(),
        onChanged: (String? observationId) {
          segmentControl.control('observationId').updateValue(observationId);
          segmentControl.control('questionId').updateValue('');
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          // todo localize
          labelText: 'Survey',
        ),
      ),
      const SizedBox(height: 16),
      // for the observation list all questions
      DropdownButtonFormField<String>(
        initialValue:
            (segmentControl.control('questionId').value as String).isEmpty
            ? null
            : (segmentControl.control('questionId').value as String),
        items: formViewModel.observations
            .whereType<QuestionnaireTask>()
            .where(
              (observation) =>
                  observation.id ==
                  segmentControl.control('observationId').value,
            )
            .expand(
              (observation) => observation.questions.questions.map(
                (question) => DropdownMenuItem<String>(
                  value: question.id,
                  child: Text(question.prompt ?? question.id),
                ),
              ),
            )
            .toSet()
            .toList(),
        onChanged: (String? questionId) {
          segmentControl.control('questionId').updateValue(questionId);
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          // todo localize
          labelText: 'Question',
        ),
      ),
    ];
  }

  List<Widget> _getSingleInterventionControls(
    FormGroup segmentControl,
    StudyScheduleControls formViewModel,
  ) {
    final totalInterventions = formViewModel.interventions.length;
    final useSimpleLabels = totalInterventions == 2;

    return [
      Row(
        children: [
          Expanded(
            child: ReactiveDropdownField<int>(
              formControl:
                  segmentControl.control('interventionIndex')
                      as FormControl<int>?,
              isExpanded: true,
              items: List.generate(
                2, // Always only A and B for single intervention
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(
                    useSimpleLabels
                        ? 'Intervention ${String.fromCharCode(65 + index)}'
                        : "Choice ${String.fromCharCode(65 + index)} (Participant's ${_ordinal(index + 1)} selection)",
                  ),
                ),
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                // todo localize
                labelText: useSimpleLabels
                    ? 'Intervention'
                    : 'Participant Choice',
                helperText: useSimpleLabels
                    ? 'Participants will compare these two interventions'
                    : 'Participants select 2 interventions; this uses their 1st or 2nd choice',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('duration') as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // todo localize
                labelText: 'Duration (days)',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
    ];
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

class ZeroValueController extends TextEditingController {
  ZeroValueController() {
    addListener(_ensureZero);
  }

  void _ensureZero() {
    if (text.isEmpty) {
      text = '0';
    }
  }
}
