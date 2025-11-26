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
                          segment.name, // Using name from segment
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
    buffer.writeln('Total Duration: $totalDuration days');

    String? calculation;
    if (segment is AlternatingScheduleSegment) {
      final numInterventions = interventions.isNotEmpty
          ? interventions.length
          : 0;
      calculation =
          '${segment.interventionDuration} (intervention duration in days) * ${segment.cycleAmount} (cycles) * $numInterventions (interventions)';
    } else if (segment is CounterBalancedScheduleSegment) {
      final numInterventions = interventions.isNotEmpty
          ? interventions.length
          : 0;
      calculation =
          '${segment.interventionDuration} (intervention duration in days) * ${segment.cycleAmount} (cycles) * $numInterventions (interventions)';
    } else if (segment is ThompsonSamplingScheduleSegment) {
      calculation =
          '${segment.interventionDuration} (intervention duration in days) * ${segment.interventionDrawAmount} (draws)';
    }

    if (calculation != null) {
      buffer.write('Calculation: $calculation');
    }

    return buffer.toString();
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
                widget.segment.name, // Using name from segment
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
        return _getAlternatingControls(segmentControl);
      case StudyScheduleSegmentType.counterBalanced:
        return _getCounterBalancedControls(segmentControl);
      case StudyScheduleSegmentType.thompsonSampling:
        return _getThompsonSamplingControls(segmentControl, formViewModel);
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

  List<Widget> _getAlternatingControls(FormGroup segmentControl) {
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

  List<Widget> _getCounterBalancedControls(FormGroup segmentControl) {
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
                observation.id == segmentControl.control('observationId').value,
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
