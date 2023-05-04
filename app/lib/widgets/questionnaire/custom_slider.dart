import 'package:flutter/material.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  //final int majorTick;
  final int minorTick;
  final Function(double) onChanged; // nullable
  final Color activeColor; // nullable
  final Color inactiveColor; // nullable
  final Color minColor;
  final Color maxColor;
  final Color thumbColor;
  final bool isColored;
  final int labelValuePrecision;
  final int tickValuePrecision;
  final bool linearStep;
  final ScaleQuestion steps; // nullable

  const CustomSlider({
    Key key,
    // required
    this.value,
    this.minValue,
    this.maxValue,
    //this.majorTick,
    this.minorTick,
    this.onChanged,
    // not required
    this.activeColor,
    this.inactiveColor,
    this.minColor,
    this.maxColor,
    this.thumbColor,
    this.isColored,
    this.labelValuePrecision = 2,
    this.tickValuePrecision = 1,
    this.linearStep = true,
    this.steps
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allocatedHeight = MediaQuery.of(context).size.height;
    final allocatedWidth = MediaQuery.of(context).size.width - 32;
    final divisions = (steps.maximum - steps.minimum) ~/ steps.step;
    //final divisions = steps.annotations.length; // (majorTick - 1) * minorTick + majorTick;
    final double valueHeight =
    allocatedHeight * 0.05 < 41 ? 41 : allocatedHeight * 0.05;
    final double tickHeight =
    allocatedHeight * 0.0125 < 20 ? 20 : allocatedHeight * 0.0125;
    // todo finetune label positions
    final labelOffset = (allocatedWidth / (divisions + 2)) * 0.5;

    final textTheme = Theme.of(context).textTheme;
    final labelTextStyle = textTheme.bodyLarge;

    List<Annotation> annotations = [...steps.annotations];
    if (annotations.isEmpty) return const SizedBox();

    // Ensure annotation order is correct for widget generation
    double startPosValue = steps.minimum;
    annotations.sort((a, b) => a.value.compareTo(b.value));
    if (steps.maximum < steps.minimum) {
      annotations = annotations.reversed.toList();
      startPosValue = steps.maximum;
    }

    // Ensure that there is always an annotation object at the very start
    final missingStartPosLabel = annotations[0].value != startPosValue;
    if (missingStartPosLabel) {
      final startPosAnnotation = Annotation()
        ..annotation = ''
        ..value = startPosValue.toInt();
      annotations = [startPosAnnotation, ...annotations];
    }

    return Column(
      children: [
        Row(
          children: List.generate(
            divisions + 1,
                (index) => Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    height: valueHeight,
                    child: index % (minorTick + 1) == 0
                        ? Text(
                      //linearStep
                        //  ? (index / (divisions - 1) * maxValue).toStringAsFixed(tickValuePrecision)
                          /*:*/ annotations.firstWhere((annotation) => annotation.value == index, orElse: () => Annotation()).annotation,
                      style: labelTextStyle.copyWith(fontWeight: (index / (divisions )) * maxValue == value
                          ? FontWeight.bold
                          : FontWeight.normal),
                      textAlign: TextAlign.center,
                    )
                        : null,
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    height: tickHeight,
                    child: VerticalDivider(
                      indent: index % (minorTick + 1) == 0 ? 2 : 6,
                      thickness: 1.8,
                      color: (index / (divisions )) * maxValue == value
                          ? thumbColor ?? primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: labelOffset),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight:
                allocatedHeight * 0.0125 < 9 ? 9 : allocatedHeight * 0.0125,
              inactiveTickMarkColor: isColored ? activeColor : null,
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              overlayColor: activeColor?.withOpacity(0.1),
              thumbColor: thumbColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              trackShape: CustomTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
              valueIndicatorTextStyle: const TextStyle(
                fontSize: 12,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isColored)
                Container(
                  height: allocatedHeight * 0.0125 < 9 ? 9 : allocatedHeight * 0.0125,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [minColor, maxColor],
                    ),
                  ),
                )
                else
                  const SizedBox.shrink(),
                Slider(
                  value: value,
                  min: minValue,
                  max: maxValue,
                  divisions: divisions,
                  onChanged: onChanged,
                  label: value.toStringAsFixed(labelValuePrecision),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}