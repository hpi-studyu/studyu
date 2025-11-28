import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_banner.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/add_schedule_block_button.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/intervention_selection_card.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_timeline.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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
        _buildStudyScheduleDescription(),
        const SizedBox(height: 24.0),
        InterventionSelectionCard(formViewModel: widget.formViewModel),
        const SizedBox(height: 24.0),
        StudyTimeline(formViewModel: widget.formViewModel),
        const SizedBox(height: 24.0),
        _buildScheduleSegmentsList(),
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

  Widget _buildStudyScheduleDescription() {
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

  Widget _buildScheduleSegmentsList() {
    return ReorderableListView(
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
            key: ObjectKey(widget.formViewModel.segmentsControl.controls[i]),
            index: i,
            segment: widget.formViewModel.segments[i],
            segmentControl:
                widget.formViewModel.segmentsControl.controls[i] as FormGroup,
            interventions: widget.formViewModel.interventions,
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final reorderedSegment = widget.formViewModel.segmentsControl.removeAt(
          oldIndex,
        );
        widget.formViewModel.segmentsControl.insert(newIndex, reorderedSegment);
        widget.formViewModel.updateSegmentsFromSegmentsControl();
      },
    );
  }
}
