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
    this.transitionDuration = 220,
    this.animationDuration = 1500,
    this.iconSize = 15.0,
    super.key,
  });

  final AsyncValue<T> state;
  final DateTime? lastSynced;
  final bool isDirty;
  final int transitionDuration;
  final int animationDuration;
  final double iconSize;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool get shouldAnimate => widget.state.isLoading || widget.state.isRefreshing;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
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
    final indicator = widget.state.when(
      data: (data) => MouseEventsRegion(builder: buildIndicator),
      error: (error, stackTrace) => Tooltip(
        message: tr.sync_failed,
        child: Icon(
          key: const ValueKey('sync_indicator_error'),
          Icons.sync_problem_outlined,
          size: widget.iconSize,
        ),
      ),
      loading: () => MouseEventsRegion(builder: buildIndicator),
    );

    return SizedBox.square(
      dimension: widget.iconSize + 3,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: widget.transitionDuration),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.center,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        child: indicator,
      ),
    );
  }

  Widget buildIndicator(BuildContext context, Set<WidgetState> states) {
    final theme = Theme.of(context);
    final isHovered = states.contains(WidgetState.hovered);
    double actualOpacity = (widget.state.isRefreshing) ? 0.5 : 0.2;
    actualOpacity += isHovered ? 0.2 : 0.0;
    final iconColor = theme.iconTheme.color!.withValues(alpha: actualOpacity);
    final savedIconColor = Colors.green.withValues(
      alpha: isHovered ? 0.85 : 0.7,
    );

    Widget dataWidget;

    if (!widget.isDirty && widget.lastSynced != null) {
      dataWidget = Tooltip(
        message:
            "${tr.sync_done}\n\n${tr.sync_last_saved}: ${widget.lastSynced!.toTimeAgoStringPrecise()}",
        child: Icon(
          key: const ValueKey('sync_indicator_saved'),
          Icons.check_circle_rounded,
          size: widget.iconSize,
          color: savedIconColor,
        ),
      );
    } else if (!widget.isDirty && widget.lastSynced == null) {
      dataWidget = Tooltip(
        message: tr.sync_initial,
        child: Icon(
          key: const ValueKey('sync_indicator_initial'),
          Icons.check_circle_rounded,
          size: widget.iconSize,
          color: savedIconColor,
        ),
      );
    } else {
      // isDirty
      dataWidget = Tooltip(
        message: tr.sync_dirty,
        child: Icon(
          key: const ValueKey('sync_indicator_dirty'),
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
          key: const ValueKey('sync_indicator_refreshing'),
          Icons.sync_rounded,
          size: widget.iconSize + 1,
          color: iconColor,
        ),
      ),
    );

    return shouldAnimate ? refreshingWidget : dataWidget;
  }
}
