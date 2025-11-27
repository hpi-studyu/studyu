import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/alternating_controls.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/baseline_controls.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/counter_balanced_controls.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/single_intervention_controls.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/thompson_sampling_controls.dart';
import 'package:studyu_designer_v2/theme.dart';

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
  bool _isExpanded = false;

  String _getSegmentDisplayName() {
    final segment = widget.segment;
    final totalInterventions = widget.formViewModel.interventions.length;

    if (segment is AlternatingScheduleSegment ||
        segment is CounterBalancedScheduleSegment) {
      List<String>? selectedIds;
      if (segment is AlternatingScheduleSegment) {
        selectedIds = segment.interventionIds;
      } else if (segment is CounterBalancedScheduleSegment) {
        selectedIds = segment.interventionIds;
      }

      final useCustomIds = selectedIds != null && selectedIds.isNotEmpty;
      final count = useCustomIds ? selectedIds.length : totalInterventions;
      final clampedCount = count > 2 ? 2 : count;

      final pattern = StringBuffer();
      for (var i = 0; i < clampedCount; i++) {
        if (i > 0) pattern.write('-');
        pattern.write(String.fromCharCode(65 + i));
      }

      final baseName = segment is AlternatingScheduleSegment
          ? 'Alternating'
          : 'Counter-Balanced';
      return '$baseName ($pattern)';
    }

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
                _getSegmentDisplayName(),
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
        return BaselineControls(segmentControl: segmentControl).build();
      case StudyScheduleSegmentType.alternating:
        return AlternatingControls(
          segmentControl: segmentControl,
          formViewModel: formViewModel,
        ).build();
      case StudyScheduleSegmentType.counterBalanced:
        return CounterBalancedControls(
          segmentControl: segmentControl,
          formViewModel: formViewModel,
        ).build();
      case StudyScheduleSegmentType.thompsonSampling:
        return ThompsonSamplingControls(
          segmentControl: segmentControl,
          formViewModel: formViewModel,
        ).build();
      case StudyScheduleSegmentType.singleIntervention:
        return SingleInterventionControls(
          segmentControl: segmentControl,
          formViewModel: formViewModel,
        ).build();
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
