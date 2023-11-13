import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';

import '../../common_views/action_popup_menu.dart';
import '../../common_views/mouse_events.dart';
import '../../theme.dart';
import '../../utils/model_action.dart';
import '../study/study_participation_badge.dart';
import '../study/study_status_badge.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudiesTableItem extends StatefulWidget {
  final Study study;
  final double itemHeight;
  final double itemPadding;
  final double rowSpacing;
  final double columnSpacing;
  final List<ModelAction> actions;
  final List<StudiesTableColumnSize> columnSizes;
  final bool isPinned;
  final void Function(Study, bool)? onPinnedChanged;
  final void Function(Study)? onTap;

  StudiesTableItem(
      {super.key,
      required this.study,
      required this.actions,
      required this.columnSizes,
      required this.isPinned,
      this.onPinnedChanged,
      this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle? mutedTextStyleIfZero(int value) {
      return (value > 0) ? null : ThemeConfig.bodyTextBackground(theme);
    }

    Icon icon(IconData iconData) {
      return Icon(
        iconData,
        color: Colors.grey,
        size: 25,
      );
    }

    Widget getRespectivePinIcon(Set<MaterialState> state) {
      if (isHoveringPin) {
        return widget.isPinned ? icon(MdiIcons.pinOff) : icon(MdiIcons.pin);
      } else {
        return widget.isPinned ? icon(MdiIcons.pin) : const SizedBox.shrink();
      }
    }

    return Container(
      height: widget.itemHeight,
      margin: EdgeInsets.only(bottom: widget.rowSpacing),
      child: LayoutBuilder(builder: (_, constraints) {
        return Material(
          color: theme.colorScheme.onPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          elevation: isHovering ? 4.0 : 1.5,
          child: InkWell(
            onTap: () => widget.onTap?.call(widget.study),
            onHover: (hover) {
              setState(() {
                isHovering = hover;
              });
            },
            hoverColor: theme.colorScheme.onPrimary,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: widget.itemPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.columnSizes[0].createContainer(
                    height: widget.itemHeight,
                    child: MouseEventsRegion(
                      onTap: () => widget.onPinnedChanged?.call(widget.study, !widget.isPinned),
                      onEnter: (_) => setState(() => isHoveringPin = true),
                      onExit: (_) => setState(() => isHoveringPin = false),
                      builder: (context, mouseEventState) {
                        return getRespectivePinIcon(mouseEventState);
                      },
                    ),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[1].createContainer(
                    child: Text(widget.study.title ?? '[Missing study title]'),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[2].createContainer(
                    child: StudyStatusBadge(
                      status: widget.study.status,
                      showPrefixIcon: false,
                      showTooltip: false,
                    ),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[3].createContainer(
                    child: StudyParticipationBadge(
                      participation: widget.study.participation,
                      center: false,
                    ),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[4].createContainer(
                      child: Text(widget.study.createdAt?.toTimeAgoString() ?? '')),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[5].createContainer(
                    child: Text(widget.study.participantCount.toString(),
                        style: mutedTextStyleIfZero(widget.study.participantCount)),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[6].createContainer(
                    child: Text(widget.study.activeSubjectCount.toString(),
                        style: mutedTextStyleIfZero(widget.study.activeSubjectCount)),
                  ),
                  SizedBox(width: widget.columnSpacing),
                  widget.columnSizes[7].createContainer(
                    child: Text(widget.study.endedCount.toString(),
                        style: mutedTextStyleIfZero(widget.study.endedCount)),
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
            ),
          ),
        );
      }),
    );
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