import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

import 'custom_slider.dart';
import 'question_widget.dart';

class ScaleQuestionWidget extends QuestionWidget {
  final ScaleQuestion question;
  final Function(Answer)? onDone;

  const ScaleQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget> {
  double? value;
  late bool sliderTouched;

  @override
  void initState() {
    super.initState();
    value = widget.question.initial;
    sliderTouched = false;
  }

  @override
  Widget build(BuildContext context) {
    final sliderRange = (widget.question.maximum - widget.question.minimum).abs();

    Color? minColor = widget.question.minColor != null ? Color(widget.question.minColor!) : null;
    Color? maxColor = widget.question.maxColor != null ? Color(widget.question.maxColor!) : null;

    final isColored = minColor != null || maxColor != null;
    if (isColored) {
      // set defaults if one or the other is undefined
      minColor ??= Colors.white;
      maxColor ??= Colors.white;
    }

    final theme = Theme.of(context);
    final coloredSliderTheme = ThemeConfig.coloredSliderTheme(theme);
    final thumbColor = isColored
        ? Color.lerp(minColor, maxColor, (value! - widget.question.minimum) / sliderRange)!.withOpacity(1)
        : null;
    final activeTrackColor = isColored ? coloredSliderTheme.activeTrackColor : null;
    final inactiveTrackColor = isColored ? coloredSliderTheme.inactiveTrackColor : null;

    return Column(
      children: [
        Stack(
          children: [
            Theme(
                data: isColored
                    ? theme.copyWith(
                        sliderTheme: SliderThemeData(
                          overlayColor: thumbColor!.withOpacity(0.5),
                        ),
                      )
                    : theme,
                child: CustomSlider(
                  minValue: widget.question.minimum,
                  maxValue: widget.question.maximum,
                  value: value,
                  minorTick: 0,
                  labelValuePrecision: 0,
                  tickValuePrecision: 0,
                  onChanged: (val) => setState(() {
                    value = val;
                    //print('Slider value (linear): $value');
                  }),
                  onChangeEnd: (val) => setState(() {
                    value = val;
                    sliderTouched = true;
                    widget.onDone!(widget.question.constructAnswer(value!));
                  }),
                  activeColor: activeTrackColor,
                  inactiveColor: inactiveTrackColor,
                  thumbColor: thumbColor,
                  minColor: minColor,
                  maxColor: maxColor,
                  isColored: isColored,
                  linearStep: false,
                  steps: widget.question,
                )),
          ],
        ),
        if (!sliderTouched)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  sliderTouched = true;
                });
                widget.onDone!(widget.question.constructAnswer(value!));
              },
              child: Text(AppLocalizations.of(context)!.done),
            ),
          )
      ],
    );
  }
}
