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
      {Key? key,
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
      this.steps})
      : super(key: key);

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

    maxFlex(int index) {
      int flexNum = 1;

      if (index > divisions || annotation(index + 1).isNotEmpty || annotation(index).isEmpty) return flexNum;

      if (index == 0) {
        int currIndex = index + 1;
        while (annotation(currIndex).isEmpty && annotation(currIndex+1).isEmpty && currIndex <= divisions) {
          currIndex++;
        }
        flexNum = currIndex;
      }

      if (index == divisions) {
        int currIndex = index - 1;
        while (annotation(currIndex).isEmpty && annotation(currIndex-1).isEmpty && currIndex >= 0) {
          currIndex--;
        }
        flexNum = divisions - currIndex;
      }
      return flexNum;
    }
    
    Alignment alignment(int index) {
      if (index == 0) return Alignment.bottomLeft;
      if (index == divisions) return Alignment.bottomRight;
      return Alignment.bottomCenter;
    }

    TextAlign textAlign(int index) {
      if (index == 0) return TextAlign.left;
      if (index == divisions) return TextAlign.right;
      return TextAlign.center;
    }

    /*
    // old: let text overflow until there is another annotation taking space
    // e.g. use table and
    UnconstrainedBox(
      //textDirection: index == (maxValue!-1) ? TextDirection.rtl : TextDirection.ltr,
        alignment: index < (maxValue!-1) ? Alignment.centerLeft : Alignment.centerRight,*/

    return Column(
      children: [
        Row(
          children: [
            for (int index = 0; index <= divisions; index++)
              Flexible(
                flex: maxFlex(index),
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
                          alignment: alignment(index),
                          child: OverflowDetectingText(
                            text: annotation(index),
                            maxLines: 3,
                            textAlign: textAlign(index),
                            overflow: TextOverflow.ellipsis,
                            alternateWidget: Column(
                              children: [
                                Text(
                                  annotation(index),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: ListTile(
                                          leading: const Icon(Icons.info_outline),
                                          title: Text("Description for axis step ${index + 1}"),
                                        ),
                                        content: Text(annotation(index)),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            style: labelTextStyle!.copyWith(
                              fontWeight: isValueSelected(index) ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                      ) :
                      Expanded(flex: 0, child: Container()),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int index = 0; index <= divisions; index++)
              Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    onChanged!(index + minValue!);
                    onChangeEnd!(index + minValue!);
                  },
                  child: Column(
                    children: [
                      if (index % (minorTick! + 1) == 0)
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: tickHeight,
                          child: VerticalDivider(
                            indent: 2,
                            thickness: 1.8,
                            color: isValueSelected(index) ? thumbColor ?? primaryColor : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
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

class OverflowDetectingText extends StatelessWidget {
  final String text;
  final Widget alternateWidget;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;

  const OverflowDetectingText({
    super.key,
    required this.text,
    required this.alternateWidget,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textSpan = TextSpan(text: text, style: style);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: maxLines ?? 2,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return alternateWidget;
        } else {
          return Text(
            text,
            maxLines: maxLines,
            overflow: overflow,
            style: style,
            textAlign: textAlign,
          );
        }
      },
    );
  }
}
