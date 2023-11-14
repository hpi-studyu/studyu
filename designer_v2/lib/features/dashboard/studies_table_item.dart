import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';

import '../../common_views/action_popup_menu.dart';
import '../../theme.dart';
import '../../utils/model_action.dart';
import '../study/study_participation_badge.dart';
import '../study/study_status_badge.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudiesTableItem extends StatefulWidget {
  final StudyGroup studyGroup;
  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final List<ModelAction> actions;
  final List<StudiesTableColumnSize> columnSizes;
  final bool isPinned;
  final void Function(StudyGroup, bool)? onPinnedChanged;
  final void Function(Study)? onTapStudy;

  StudiesTableItem(
      {super.key,
      required this.studyGroup,
      required this.actions,
      required this.columnSizes,
      required this.isPinned,
      this.onPinnedChanged,
      this.onTapStudy,
      this.itemHeight = 60.0,
      this.itemPadding = 10.0,
      this.rowSpacing = 9.0,
      this.columnSpacing = 10.0}) {
    assert(columnSizes.length == 9);
  }

  @override
  State<StudiesTableItem> createState() => _StudiesTableItemState();
}

class _StudiesTableItemState extends State<StudiesTableItem> {
  bool isHovering = false;
  bool isHoveringPin = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      //height: widget.itemHeight,
      margin: EdgeInsets.only(bottom: widget.rowSpacing),
      child: LayoutBuilder(builder: (_, constraints) {
        return Material(
          color: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
                color:
                    widget.isPinned ? theme.colorScheme.primary.withAlpha(70) : Colors.transparent,
                width: 1.0),
          ),
          elevation: isHovering ? 4.0 : 1.5,
          child: _buildRow(theme, widget.studyGroup),
        );
      }),
    );
  }

  Widget _buildRow(ThemeData theme, StudyGroup studyGroup) {
    final row = _buildSingleStudyOrGroupHeaderRow(theme, studyGroup);
    final List<Widget> subRows = [];

    if (!studyGroup.isSingleStudy && isExpanded) {
      for (final study in studyGroup.studies) {
        subRows.add(_buildSingleStudyOrGroupHeaderRow(theme, StudyGroup.single(study)));
        subRows.add(const Divider(
          thickness: 0.3,
        ));
      }
      subRows.removeLast();
      subRows.add(const Divider(
        thickness: 0.3,
        color: Colors.transparent,
      ));
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

  Widget _buildSingleStudyOrGroupHeaderRow(ThemeData theme, StudyGroup studyGroup) {
    final normalTextStyle = isExpanded && !studyGroup.isSingleStudy
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;

    TextStyle? mutedTextStyleIfZero(int value) {
      return (value > 0)
          ? normalTextStyle
          : ThemeConfig.bodyTextBackground(theme).merge(normalTextStyle);
    }

    final row = InkWell(
      onTap: () {
        if (studyGroup.isSingleStudy) {
          widget.onTapStudy?.call(studyGroup.first);
          return;
        }

        setState(() {
          isExpanded = !isExpanded;
        });
      },
      onHover: (hover) {
        setState(() {
          isHovering = hover;
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
              children: [
                widget.columnSizes[0].createContainer(
                    height: widget.itemHeight,
                    child: !studyGroup.isSingleStudy
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[1].createContainer(
                  child: Text(
                    studyGroup.title ?? '[Missing study title]',
                    style: normalTextStyle,
                  ),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[2].createContainer(
                  child: studyGroup.isSingleStudy
                      ? StudyStatusBadge(
                          status: studyGroup.first.status,
                          showPrefixIcon: false,
                          showTooltip: false,
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[3].createContainer(
                  child: studyGroup.isSingleStudy
                      ? StudyParticipationBadge(
                          participation: studyGroup.first.participation,
                          center: false,
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[4].createContainer(
                    child: Text(studyGroup.createdAt?.toTimeAgoString() ?? '',
                        style: normalTextStyle)),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[5].createContainer(
                  child: Text(studyGroup.participantCount.toString(),
                      style: mutedTextStyleIfZero(studyGroup.participantCount)),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[6].createContainer(
                  child: Text(studyGroup.activeSubjectCount.toString(),
                      style: mutedTextStyleIfZero(studyGroup.activeSubjectCount)),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[7].createContainer(
                  child: Text(studyGroup.endedCount.toString(),
                      style: mutedTextStyleIfZero(studyGroup.endedCount)),
                ),
                SizedBox(width: widget.columnSpacing),
                widget.columnSizes[8].createContainer(
                  child: _buildActionMenu(context, widget.actions),
                ),
                SizedBox(
                  width: widget.columnSpacing,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return !studyGroup.isSingleStudy
        ? Material(
            color: theme.colorScheme.onPrimary,
            elevation: isExpanded ? 1.5 : 0.0,
            child: row,
          )
        : row;
  }

  Widget _buildActionMenu(BuildContext context, List<ModelAction> actions) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: ActionPopUpMenuButton(
        actions: actions,
        orientation: Axis.horizontal,
        triggerIconColor: ThemeConfig.bodyTextMuted(theme).color?.faded(0.6),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      ),
    );
  }
}
