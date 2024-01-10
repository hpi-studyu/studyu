import 'package:flutter/material.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

class CustomSlider extends StatelessWidget {
  final double? value;
  final double? minValue;
  final double? maxValue;

  //final int majorTick;
  final int? minorTick;
  final Function(double)? onChanged; // nullable
  final Function(double)? onChangeEnd; // nullable
  final Color? activeColor; // nullable
  final Color? inactiveColor; // nullable
  final Color? minColor;
  final Color? maxColor;
  final Color? thumbColor;
  final bool isColored;
  final int labelValuePrecision;
  final int tickValuePrecision;
  final bool linearStep;
  final AnnotatedScaleQuestion? steps; // nullable

  const CustomSlider(
      {super.key,
      // required
      this.value,
      this.minValue,
      this.maxValue,
      //this.majorTick,
      this.minorTick,
      this.onChanged,
      this.onChangeEnd,
      // not required
      this.activeColor,
      this.inactiveColor,
      this.minColor,
      this.maxColor,
      this.thumbColor,
      this.isColored = false,
      this.labelValuePrecision = 2,
      this.tickValuePrecision = 1,
      this.linearStep = true,
      this.steps});

  @override
  Widget build(BuildContext context) {
    final allocatedHeight = MediaQuery.of(context).size.height;
    final allocatedWidth = MediaQuery.of(context).size.width - 32; // -32 horizontal padding
    final divisions = (steps!.maximum - steps!.minimum) ~/ steps!.step;
    //final divisions = steps.annotations.length; // (majorTick - 1) * minorTick + majorTick;
    // final double valueHeight = allocatedHeight * 0.05 < 41 ? 41 : allocatedHeight * 0.05;
    final double tickHeight = allocatedHeight * 0.0125 < 20 ? 20 : allocatedHeight * 0.0125;
    // todo finetune label positions
    final labelOffset = (allocatedWidth / (divisions + 2)) * 0.5;

    final textTheme = Theme.of(context).textTheme;
    final labelTextStyle = textTheme.bodyLarge;

    List<Annotation> annotations = [...steps!.annotations];
    if (annotations.isEmpty) return const SizedBox.shrink();

    // Ensure annotation order is correct for widget generation
    double startPosValue = steps!.minimum;
    annotations.sort((a, b) => a.value.compareTo(b.value));
    if (steps!.maximum < steps!.minimum) {
      annotations = annotations.reversed.toList();
      startPosValue = steps!.maximum;
    }

    // Ensure that there is always an annotation object at the very start
    final missingStartPosLabel = annotations[0].value != startPosValue;
    if (missingStartPosLabel) {
      final startPosAnnotation = Annotation()
        ..annotation = ''
        ..value = startPosValue.toInt();
      annotations = [startPosAnnotation, ...annotations];
    }

    bool isValueSelected(int index) {
      return index + minValue! == value;
    }

    String annotation(index) => annotations
        .firstWhere((annotation) => annotation.value == index + minValue!, orElse: () => Annotation())
        .annotation;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            divisions + 1,
            (index) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  onChanged!(index + minValue!);
                  onChangeEnd!(index + minValue!);
                },
                child: Column(
                  children: [
                    index % (minorTick! + 1) == 0 && annotation(index).isNotEmpty
                        ? Container(
                            alignment: Alignment.bottomCenter,
                            //height: valueHeight,
                            child: Text(
                              //linearStep
                              //  ? (index / (divisions - 1) * maxValue).toStringAsFixed(tickValuePrecision)
                              /*:*/
                              annotation(index),
                              style: labelTextStyle!
                                  .copyWith(fontWeight: isValueSelected(index) ? FontWeight.bold : FontWeight.normal),
                              textAlign: TextAlign.center,
                            ))
                        : const SizedBox.shrink(),
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: tickHeight,
                      child: VerticalDivider(
                        indent: index % (minorTick! + 1) == 0 ? 2 : 6,
                        thickness: 1.8,
                        color: isValueSelected(index) ? thumbColor ?? primaryColor : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: labelOffset),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: allocatedHeight * 0.0125 < 9 ? 9 : allocatedHeight * 0.0125,
              inactiveTickMarkColor: isColored ? activeColor : null,
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              overlayColor: activeColor?.withOpacity(0.1),
              thumbColor: thumbColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
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
                        colors: [minColor!, maxColor!],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Slider(
                  value: value!,
                  min: minValue!,
                  max: maxValue!,
                  divisions: divisions,
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  label: value!.toStringAsFixed(labelValuePrecision),
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
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
