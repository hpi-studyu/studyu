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
    Key? key,
  }) : super(key: key);

  /// The text displayed as the button label
  final String text;

  /// The icon displayed to the left of the label
  final IconData? icon;

  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed;

  final String tooltip;
  final String tooltipDisabled;

  final bool enabled;

  final FutureFactory? onPressedFuture;

  bool get isDisabled =>
      !enabled || (onPressed == null && onPressedFuture == null);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  Future trackedFuture = Future.value(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = ElevatedButton.styleFrom(
      onPrimary: Theme.of(context).colorScheme.onPrimary,
      primary: Theme.of(context).colorScheme.primary,
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    final tooltipMessage =
        (!widget.isDisabled) ? widget.tooltip : widget.tooltipDisabled;

    onButtonPressed() {
      widget.onPressed?.call();
      if (widget.onPressedFuture != null) {
        setState(() {
          trackedFuture = widget.onPressedFuture!();
        });
      }
    }

    FutureBuilder _trackedFutureBuilder(
        {required WidgetBuilder whenComplete,
        required WidgetBuilder otherwise}) {
      return FutureBuilder(
          future: trackedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return whenComplete(context);
            }
            return otherwise(context);
          });
    }

    final loadingIndicator = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: SizedBox(
          width: theme.iconTheme.size ?? 14.0,
          height: theme.iconTheme.size ?? 14.0,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );

    if (widget.icon != null) {
      return Tooltip(
          message: tooltipMessage,
          child: ElevatedButton.icon(
            style: primaryStyle,
            onPressed: (widget.isDisabled) ? null : onButtonPressed,
            icon: widget.isLoading
                ? const SizedBox.shrink()
                : _trackedFutureBuilder(
                    whenComplete: (context) => Icon(widget.icon),
                    otherwise: (context) => const SizedBox.shrink(),
                  ),
            label: _trackedFutureBuilder(
              whenComplete: (context) =>
                  Text(widget.text, textAlign: TextAlign.center),
              otherwise: (context) => loadingIndicator,
            ),
          ));
    }

    return Tooltip(
        message: tooltipMessage,
        child: ElevatedButton(
          style: primaryStyle,
          onPressed: (widget.isDisabled) ? null : onButtonPressed,
          child: widget.isLoading
              ? loadingIndicator
              : _trackedFutureBuilder(
                  whenComplete: (context) =>
                      Text(widget.text, textAlign: TextAlign.center),
                  otherwise: (context) => loadingIndicator,
                ),
        ));
  }
}
