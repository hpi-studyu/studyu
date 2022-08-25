import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class SyncIndicator<T> extends StatefulWidget {
  const SyncIndicator({
    required this.state,
    required this.isDirty,
    this.lastSynced,
    this.animationDuration = 1500,
    this.iconSize = 15.0,
    Key? key
  }) : super(key: key);

  final AsyncValue<T> state;
  final DateTime? lastSynced;
  final bool isDirty;
  final int animationDuration;
  final double iconSize;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool get shouldAnimate => widget.state.isRefreshing;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
      upperBound: 1,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    if (!shouldAnimate) {
      _animationController.stop();
    }
  }

  @override
  void didUpdateWidget(SyncIndicator oldWidget) {
    _animationController.reset();
    if (shouldAnimate) {
      _animationController.repeat();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.state.when(
      data: (data) => MouseEventsRegion(builder: buildDataWidget),
      error: (error, stackTrace) => Tooltip(
        message: tr.changes_could_not_be_saved,
        child: Icon(Icons.sync_problem_outlined, size: widget.iconSize),
      ),
      loading: () => Container(), // hide on initial load
    );
  }

  Widget buildDataWidget(BuildContext context, Set<MaterialState> states) {
    final theme = Theme.of(context);
    final isHovered = states.contains(MaterialState.hovered);
    double actualOpacity = (widget.state.isRefreshing) ? 0.5 : 0.2;
    actualOpacity += (isHovered) ? 0.2 : 0.0;
    final iconColor = theme.iconTheme.color!.withOpacity(actualOpacity);

    Widget dataWidget;

    if (!widget.isDirty && widget.lastSynced != null) {
      dataWidget = Tooltip(
        message: tr.all_changes_saved + "\n\n"
            + tr.last_saved + " "
            + widget.lastSynced!.toTimeAgoString(),
        child: Icon(Icons.check_circle_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    } else if (!widget.isDirty && widget.lastSynced == null) {
      dataWidget = Tooltip(
        message: tr.all_changes_saved,
        //message: "Any changes will be saved automatically.".hardcoded,
        child: Icon(Icons.check_circle_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    } else { // isDirty
      dataWidget = Tooltip(
        message: tr.unsaved_changes,
        child: Icon(Icons.sync_disabled_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    }

    final refreshingWidget = Tooltip(
      message: tr.saving_changes,
      child: RotationTransition(
        turns: _animation,
        child: Icon(Icons.sync_rounded,
          size: widget.iconSize + 1,
          color: iconColor,
        ),
      ),
    );

    return (widget.state.isRefreshing) ? refreshingWidget : dataWidget;
  }
}
