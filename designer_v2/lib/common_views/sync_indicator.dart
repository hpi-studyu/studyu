import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

abstract class ISyncIndicatorViewModel {
  AsyncValue get syncState;
  bool get isDirty;
  DateTime? get lastSynced;
}

class SyncIndicator<T> extends StatefulWidget {
  const SyncIndicator({
    required this.state,
    required this.isDirty,
    this.lastSynced,
    this.animationDuration = 1500,
    this.iconSize = 15.0,
    super.key,
  });

  final AsyncValue<T> state;
  final DateTime? lastSynced;
  final bool isDirty;
  final int animationDuration;
  final double iconSize;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool get shouldAnimate => widget.state.isLoading || widget.state.isRefreshing;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.state.when(
      data: (data) => MouseEventsRegion(builder: buildIndicator),
      error: (error, stackTrace) => Tooltip(
        message: tr.sync_failed,
        child: Icon(Icons.sync_problem_outlined, size: widget.iconSize),
      ),
      loading: () => MouseEventsRegion(builder: buildIndicator),
    );
  }

  Widget buildIndicator(BuildContext context, Set<MaterialState> states) {
    final theme = Theme.of(context);
    final isHovered = states.contains(MaterialState.hovered);
    double actualOpacity = (widget.state.isRefreshing) ? 0.5 : 0.2;
    actualOpacity += (isHovered) ? 0.2 : 0.0;
    final iconColor = theme.iconTheme.color!.withOpacity(actualOpacity);

    Widget dataWidget;

    if (!widget.isDirty && widget.lastSynced != null) {
      dataWidget = Tooltip(
        message: "${tr.sync_done}\n\n${tr.sync_last_saved}: ${widget.lastSynced!.toTimeAgoStringPrecise()}",
        child: Icon(
          Icons.check_circle_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    } else if (!widget.isDirty && widget.lastSynced == null) {
      dataWidget = Tooltip(
        message: tr.sync_initial,
        child: Icon(
          Icons.check_circle_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    } else {
      // isDirty
      dataWidget = Tooltip(
        message: tr.sync_dirty,
        child: Icon(
          Icons.sync_disabled_rounded,
          size: widget.iconSize,
          color: iconColor,
        ),
      );
    }

    final refreshingWidget = Tooltip(
      message: tr.sync_saving,
      child: RotationTransition(
        turns: _animation,
        child: Icon(
          Icons.sync_rounded,
          size: widget.iconSize + 1,
          color: iconColor,
        ),
      ),
    );

    return (shouldAnimate) ? refreshingWidget : dataWidget;
  }
}
