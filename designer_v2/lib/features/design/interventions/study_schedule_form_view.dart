import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
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
    formViewModel.segmentsControl.valueChanges.listen((_) {
      formViewModel.updateSegmentsFromSegmentsControl();
    });

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _studyScheduleDescription(),
        const SizedBox(height: 16.0),
        // todo localize
        Text(
          "Total Duration: ${widget.formViewModel.getTotalDuration()} days",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // reduce the horizontal padding so items can use more available width
        ReorderableListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          buildDefaultDragHandles: false,
          children: <Widget>[
            for (
              int i = 0;
              i < widget.formViewModel.segmentsControl.controls.length;
              i++
            )
              ExpandableSegementItem(
                formViewModel: widget.formViewModel,
                key: Key(i.toString()),
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
        // make the add-controls responsive as well
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                DropdownButton<StudyScheduleSegmentType>(
                  value: selectedSegmentType,
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  onChanged: (StudyScheduleSegmentType? value) {
                    setState(() {
                      selectedSegmentType = value!;
                    });
                  },
                  items: allSegmentTypes.map((StudyScheduleSegmentType type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.string),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20),
                // todo localize
                PrimaryButton(
                  text: 'Add to schedule',
                  onPressed: () {
                    widget.formViewModel.addFormGroupToSegments(
                      widget.formViewModel.createFormGroup(selectedSegmentType),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _studyScheduleDescription() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: tr.study_schedule_banner_description,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
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
        Expanded(
          child: TextParagraph(
            text: description,
            style: ThemeConfig.bodyTextMuted(theme),
          ),
        ),
      ],
    );
  }
}

class ExpandableSegementItem extends StatefulWidget {
  final int index;
  final StudyScheduleSegment segment;
  final FormGroup segmentControl;
  final List<Intervention> interventions;

  final StudyScheduleControls formViewModel;

  const ExpandableSegementItem({
    super.key,
    required this.formViewModel,
    required this.index,
    required this.segment,
    required this.segmentControl,
    required this.interventions,
  });

  @override
  State<ExpandableSegementItem> createState() => _ExpandableSegementItemState();
}

class _ExpandableSegementItemState extends State<ExpandableSegementItem> {
  @override
  Widget build(BuildContext context) {
    final duration = widget.segment.getDuration(widget.interventions);
    final type = widget.segment.type;

    return ExpansionTile(
      title: Text(widget.segment.name),
      // todo localize
      subtitle: Text("Duration: $duration days"),
      leading: ReorderableDragStartListener(
        index: widget.index,
        child: const Icon(Icons.drag_handle),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          widget.formViewModel.deleteSegment(widget.index);
        },
      ),
      children: [
        Wrap(
          runSpacing: 24.0,
          children: _getChildrenBasedOnType(
            type,
            widget.segmentControl,
            widget.formViewModel,
          ),
        ),
      ],
    );
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
      case StudyScheduleSegmentType.thompsonSampling:
        return _getThompsonSamplingControls(segmentControl, formViewModel);
      default:
        return [];
    }
  }

  List<Widget> _getBaselineControls(FormGroup segmentControl) {
    return [
      const SizedBox(height: 1, width: 20),
      ReactiveTextField(
        formControl:
            segmentControl.control('duration') as FormControl<dynamic>?,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          // todo localize
          labelText: 'Duration',
        ),
        controller: ZeroValueController(),
      ),
      const SizedBox(height: 1, width: 20),
    ];
  }

  List<Widget> _getAlternatingControls(FormGroup segmentControl) {
    return [
      const SizedBox(height: 1, width: 20),
      ReactiveTextField(
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
      ReactiveTextField(
        formControl:
            segmentControl.control('cycleAmount') as FormControl<dynamic>?,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          // todo localize
          labelText: 'Cycle Amount',
        ),
        controller: ZeroValueController(),
      ),
      const SizedBox(height: 1, width: 20),
    ];
  }
}

List<Widget> _getThompsonSamplingControls(
  FormGroup segmentControl,
  StudyScheduleControls formViewModel,
) {
  return [
    const SizedBox(height: 1, width: 20),
    ReactiveTextField(
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
    ReactiveTextField(
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
    // todo localize
    const Text("Deciding metric"),
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
        segmentControl.control('observationId').updateValue(observationId)
            as FormControl<dynamic>?;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        // todo localize
        labelText: 'Survey',
      ),
    ),
    // for the observation list all questions
    DropdownButtonFormField<String>(
      initialValue:
          (segmentControl.control('observationId').value as String).isEmpty
          ? null
          : (segmentControl.control('observationId').value as String),
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
          .toList(),
      onChanged: (String? questionId) {
        segmentControl.control('questionId').updateValue(questionId)
            as FormControl<dynamic>?;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        // todo localize
        labelText: 'Question',
      ),
    ),
    const SizedBox(height: 1, width: 20),
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
