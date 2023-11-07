import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.text,
    this.icon = Icons.add,
    this.tooltip = "",
    this.tooltipDisabled = "",
    this.isLoading = false,
    this.onPressed,
    this.onPressedFuture,
    this.enabled = true,
    this.showLoadingEarliestAfterMs = 100,
    this.innerPadding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
    this.minimumSize,
    super.key,
  });

  /// The text displayed as the button label
  final String text;

  /// The icon displayed to the left of the label
  final IconData? icon;

  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;
  final int showLoadingEarliestAfterMs;

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed;

  final String tooltip;
  final String tooltipDisabled;

  final bool enabled;

  final FutureFactory? onPressedFuture;

  final EdgeInsets innerPadding;

  bool get isDisabled => !enabled || (onPressed == null && onPressedFuture == null);

  final Size? minimumSize;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  Future trackedFuture = Future.value(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = ElevatedButton.styleFrom(
      foregroundColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.primary,
      minimumSize: widget.minimumSize,
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    final tooltipMessage = (!widget.isDisabled) ? widget.tooltip : widget.tooltipDisabled;

    onButtonPressed() {
      widget.onPressed?.call();
      if (widget.onPressedFuture != null) {
        final future = widget.onPressedFuture!().whenComplete(() {
          if (mounted) {
            setState(() {
              trackedFuture = Future.value(null);
            });
          }
        });
        Future.delayed(Duration(milliseconds: widget.showLoadingEarliestAfterMs), () {
          if (mounted) {
            setState(() {
              trackedFuture = future;
            });
          }
        });
      }
    }

    FutureBuilder trackedFutureBuilder({
      required WidgetBuilder otherwise,
      required WidgetBuilder whenActive,
    }) {
      return FutureBuilder(
        future: trackedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return whenActive(context);
          }
          return otherwise(context);
        },
      );
    }

    Widget visibilityDuringLoading(WidgetBuilder child, {visible = true}) {
      final loadingAlpha = visible ? 1.0 : 0.0;
      return trackedFutureBuilder(
        whenActive: (context) => Opacity(
          opacity: loadingAlpha,
          child: child(context),
        ),
        otherwise: (context) => Opacity(
          opacity: (widget.isLoading) ? loadingAlpha : (1 - loadingAlpha),
          child: child(context),
        ),
      );
    }

    final loadingIndicator = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: SizedBox(
        width: theme.iconTheme.size ?? 14.0,
        height: theme.iconTheme.size ?? 14.0,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      ),
    );

    Widget stackWithLoadingIndicator(Widget child) {
      return IntrinsicWidth(
        child: Stack(
          children: [
            Center(
              child: child,
            ),
            IgnorePointer(
              child: visibilityDuringLoading(
                (context) => Center(child: loadingIndicator),
                visible: true,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.icon != null) {
      return Tooltip(
        message: tooltipMessage,
        child: stackWithLoadingIndicator(
          ElevatedButton(
            style: primaryStyle,
            onPressed: (widget.isDisabled) ? null : onButtonPressed,
            child: visibilityDuringLoading(
              (context) => Padding(
                padding: widget.innerPadding,
                child: Row(
                  children: [
                    Container(
                      child: visibilityDuringLoading(
                        (context) => Icon(widget.icon),
                        visible: false,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(widget.text, textAlign: TextAlign.center),
                  ],
                ),
              ),
              visible: false,
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltipMessage,
      child: stackWithLoadingIndicator(
        ElevatedButton(
          style: primaryStyle,
          onPressed: (widget.isDisabled) ? null : onButtonPressed,
          child: visibilityDuringLoading(
            (context) => Padding(
              padding: widget.innerPadding,
              child: Text(widget.text, textAlign: TextAlign.center),
            ),
            visible: false,
          ),
        ),
      ),
    );
  }
}
