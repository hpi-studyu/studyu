import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:collection/collection.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/features/study/study_participation_badge.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

import '../study/study_type_badge.dart';

class StudiesTableItem extends StatefulWidget {
  final StudyGroup studyGroup;
  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final List<ModelAction> actions;
  final ActionsProviderAt<StudyGroup> getSubActions;
  final Map<StudiesTableColumn, StudiesTableColumnSize> columnDefinitions;
  final bool isPinned;
  final bool isExpanded;
  final TextStyle? normalTextStyle;
  final void Function(StudyGroup, bool)? onPinnedChanged;
  final void Function(Study)? onTapStudy;
  final void Function(Study)? onExpandStudy;

  const StudiesTableItem(
      {super.key,
      required this.studyGroup,
      required this.actions,
      required this.getSubActions,
      required this.columnDefinitions,
      required this.isPinned,
      required this.isExpanded,
      this.normalTextStyle,
      this.onPinnedChanged,
      this.onTapStudy,
      this.onExpandStudy,
      this.itemHeight = 60.0,
      this.itemPadding = 10.0,
      this.rowSpacing = 9.0,
      this.columnSpacing = 10.0});

  @override
  State<StudiesTableItem> createState() => _StudiesTableItemState();
}

class _StudiesTableItemState extends State<StudiesTableItem> {
  Study? hoveredStudy;
  bool get isHovering => hoveredStudy != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: widget.rowSpacing),
      child: LayoutBuilder(builder: (_, constraints) {
        return Material(
          color: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            side: BorderSide(
                color: widget.isPinned
                    ? theme.colorScheme.primary.withOpacity(0.6)
                    : theme.colorScheme.primaryContainer.withOpacity(0.9),
                width: isHovering ? 1.5 : 0.75),
          ),
          elevation: 0.0,
          child: _buildRow(theme, widget.studyGroup),
        );
      }),
    );
  }

  Widget _buildRow(ThemeData theme, StudyGroup studyGroup) {
    if (studyGroup.standaloneOrTemplate is Template) {
      final participantCount = studyGroup.subStudies.map((s) => s.participantCount).sum;
      final activeSubjectCount = studyGroup.subStudies.map((s) => s.activeSubjectCount).sum;
      final endedCount = studyGroup.subStudies.map((s) => s.endedCount).sum;

      final row = _buildStudyRow(
        theme,
        studyGroup.standaloneOrTemplate,
        actions: widget.actions,
        participantCount: participantCount,
        activeSubjectCount: activeSubjectCount,
        endedCount: endedCount,
      );
      final List<Widget> subRows = [];

      if (widget.isExpanded && studyGroup.subStudies.isNotEmpty) {
        subRows.add(Divider(
          thickness: isHovering ? 1.5 : 0.75,
          color: theme.colorScheme.primaryContainer.withOpacity(0.9),
          height: 0.0,
        ));
        for (final subStudy in studyGroup.subStudies) {
          final subActions = widget.getSubActions(studyGroup, studyGroup.subStudies.indexOf(subStudy));
          subRows.add(_buildStudyRow(theme, subStudy, actions: subActions));
        }
      }

      return Column(
        children: [
          row,
          Column(
            children: subRows,
          )
        ],
      );
    }

    return _buildStudyRow(theme, studyGroup.standaloneOrTemplate, actions: widget.actions);
  }

  TextStyle? _mutedTextStyleIfZero(int value) {
    return (value > 0)
        ? widget.normalTextStyle
        : ThemeConfig.bodyTextBackground(Theme.of(context)).merge(widget.normalTextStyle);
  }

  Widget _buildStudyRow(ThemeData theme, Study study,
      {required List<ModelAction> actions, int? participantCount, int? activeSubjectCount, int? endedCount}) {
    participantCount ??= study.participantCount;
    activeSubjectCount ??= study.activeSubjectCount;
    endedCount ??= study.endedCount;

    final List<Widget> columnRows = [];
    for (final columnDefinition in widget.columnDefinitions.entries) {
      columnRows.add(columnDefinition.value.createContainer(
          child: _buildRowColumn(columnDefinition.key, study,
              actions: actions,
              participantCount: participantCount,
              activeSubjectCount: activeSubjectCount,
              endedCount: endedCount),
          height: columnDefinition.key == StudiesTableColumn.expand ? widget.itemHeight : null));
      if (!columnDefinition.value.collapsed) {
        columnRows.add(SizedBox(width: widget.columnSpacing));
      }
    }

    final row = InkWell(
      onTap: () {
        widget.onTapStudy?.call(study);
      },
      onHover: (hover) {
        setState(() {
          hoveredStudy = hover ? study : null;
        });
      },
      hoverColor: theme.colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.itemPadding),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: columnRows,
            ),
          ],
        ),
      ),
    );
    return row;
  }

  Widget _buildRowColumn(StudiesTableColumn column, Study study,
      {required List<ModelAction> actions,
      required int participantCount,
      required int activeSubjectCount,
      required int endedCount}) {
    switch (column) {
      case StudiesTableColumn.expand:
        return _buildExpand(study);
      case StudiesTableColumn.title:
        return _buildTitle(study);
      case StudiesTableColumn.type:
        return _buildType(study);
      case StudiesTableColumn.status:
        return _buildStatus(study);
      case StudiesTableColumn.participation:
        return _buildParticipation(study);
      case StudiesTableColumn.createdAt:
        return _buildCreatedAt(study);
      case StudiesTableColumn.enrolled:
        return _buildEnrolled(participantCount);
      case StudiesTableColumn.active:
        return _buildActive(activeSubjectCount);
      case StudiesTableColumn.completed:
        return _buildCompleted(endedCount);
      case StudiesTableColumn.action:
        return _buildAction(actions);
    }
  }

  Widget _buildExpand(Study study) {
    return study.isTemplate
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  if (study.isTemplate) {
                    widget.onExpandStudy?.call(study);
                  }
                },
                icon: AnimatedRotation(
                  turns: widget.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                )),
          )
        : (study.isSubStudy && hoveredStudy == study
            ? const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: Colors.grey,
                  size: 16,
                ),
              )
            : const SizedBox.shrink());
  }

  Widget _buildTitle(Study study) {
    return Text(
      study.title ?? '[Missing study title]',
      style: widget.normalTextStyle,
      maxLines: 3,
      overflow: TextOverflow.fade,
    );
  }

  Widget _buildType(Study study) {
    return StudyTypeBadge(
      studyType: study.type,
    );
  }

  Widget _buildStatus(Study study) {
    return StudyStatusBadge(
      status: study.status,
      showPrefixIcon: false,
      showTooltip: false,
    );
  }

  Widget _buildParticipation(Study study) {
    return StudyParticipationBadge(
      participation: study.participation,
      center: false,
    );
  }

  Widget _buildCreatedAt(Study study) {
    return Text(
      study.createdAt?.toTimeAgoString() ?? '',
      style: widget.normalTextStyle,
      maxLines: 3,
      overflow: TextOverflow.fade,
    );
  }

  Widget _buildEnrolled(int participantCount) {
    return Text(participantCount.toString(), style: _mutedTextStyleIfZero(participantCount));
  }

  Widget _buildActive(int activeSubjectCount) {
    return Text(activeSubjectCount.toString(), style: _mutedTextStyleIfZero(activeSubjectCount));
  }

  Widget _buildCompleted(int endedCount) {
    return Text(endedCount.toString(), style: _mutedTextStyleIfZero(endedCount));
  }

  Widget _buildAction(List<ModelAction> actions) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: ActionPopUpMenuButton(
        actions: actions,
        triggerIconColor: ThemeConfig.bodyTextMuted(theme).color?.faded(0.6),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      ),
    );
  }
}
