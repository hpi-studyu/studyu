import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MouseEventsRegionBuilder = Widget Function(BuildContext context, Set<MaterialState> state);

typedef MaterialStatesChangedCallback = void Function(Set<MaterialState> state);

/// Helper widget that allows specifying both [onHover] and [onTap] callbacks
/// for the widget it contains while exposing the current interaction state
/// as a [WidgetInteractionState] to the child widget [builder]
class MouseEventsRegion extends StatefulWidget {
  const MouseEventsRegion(
      {required this.builder,
      this.onStateChanged,
      this.onHover,
      this.onTap,
      this.onEnter,
      this.onExit,
      this.cursor = defaultCursor,
      this.autoselectCursor = true,
      super.key});

  final MouseEventsRegionBuilder builder;
  final MaterialStatesChangedCallback? onStateChanged;

  final GestureTapCallback? onTap;
  final PointerHoverEventListener? onHover;
  final PointerEnterEventListener? onEnter;
  final PointerExitEventListener? onExit;

  final bool autoselectCursor;
  final SystemMouseCursor cursor;
  static const defaultCursor = SystemMouseCursors.basic;

  SystemMouseCursor get autoCursor {
    if (!autoselectCursor || cursor != defaultCursor) {
      return cursor;
    }
    if (onTap != null) {
      return SystemMouseCursors.click;
    }
    return SystemMouseCursors.basic;
  }

  @override
  State<MouseEventsRegion> createState() => _MouseEventsRegionState();
}

class _MouseEventsRegionState extends State<MouseEventsRegion> {
  late final MaterialStatesController statesController;

  void handleStatesControllerChange() {
    if (widget.onStateChanged != null) {
      widget.onStateChanged!(statesController.value);
    }
    // Force a rebuild to resolve MaterialStateProperty properties
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    statesController = MaterialStatesController();
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => statesController.update(MaterialState.pressed, true),
      onTapUp: (_) => statesController.update(MaterialState.pressed, false),
      onTapCancel: () => statesController.update(MaterialState.pressed, false),
      child: MouseRegion(
          cursor: widget.autoCursor,
          onHover: (e) {
            if (widget.onHover != null) {
              widget.onHover!(e);
            }
          },
          onEnter: (e) {
            statesController.update(MaterialState.hovered, true);
            if (widget.onExit != null) {
              widget.onEnter!(e);
            }
          },
          onExit: (e) {
            statesController.update(MaterialState.hovered, false);
            if (widget.onExit != null) {
              widget.onExit!(e);
            }
          },
          child: widget.builder(context, statesController.value)),
    );
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    statesController.dispose();
    super.dispose();
  }
}
