import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../util/intervention.dart';
import '../../../../widgets/intervention_card.dart';

class ProgressRow extends StatefulWidget {
  final ParseUserStudy study;

  const ProgressRow({Key key, this.study}) : super(key: key);
  @override
  _ProgressRowState createState() => _ProgressRowState();
}

class _ProgressRowState extends State<ProgressRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentPhase = widget.study.getInterventionIndexForDate(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.run, size: 30),
              SizedBox(width: 8),
              ...intersperseIndexed(
                  (index) => Expanded(
                        child: Divider(
                          indent: 5,
                          endIndent: 5,
                          thickness: 3,
                          color: currentPhase > index ? theme.primaryColor : theme.disabledColor,
                        ),
                      ),
                  widget.study.getInterventionsInOrder().asMap().entries.map((entry) {
                    return InterventionSegment(
                      intervention: entry.value,
                      isCurrent: currentPhase == entry.key,
                      isFuture: currentPhase < entry.key,
                      phaseDuration: widget.study.schedule.phaseDuration,
                      percentCompleted: widget.study.percentCompletedForPhase(entry.key),
                      percentMissed: widget.study.percentMissedForPhase(entry.key, DateTime.now()),
                    );
                  })),
              SizedBox(width: 8),
              Icon(MdiIcons.flagCheckered, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class InterventionSegment extends StatelessWidget {
  final Intervention intervention;
  final double percentCompleted;
  final double percentMissed;
  final bool isCurrent;
  final bool isFuture;
  final int phaseDuration;

  const InterventionSegment(
      {@required this.intervention,
      @required this.percentCompleted,
      @required this.percentMissed,
      @required this.isCurrent,
      @required this.isFuture,
      @required this.phaseDuration,
      Key key})
      : super(key: key);

  List<Widget> buildSeparators(int nbSeparators) {
    final sep = <Widget>[];
    for (var i = 0; i < nbSeparators; i++) {
      sep.add(
        Transform.rotate(
          angle: i * 1 / nbSeparators * 2 * pi,
          child: SizedBox(
            width: 2,
            height: 40,
            child: Column(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 10,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      );
    }
    return sep;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFuture ? Colors.grey : (isCurrent ? theme.accentColor : theme.primaryColor);

    final emptyColor = Color.alphaBlend(theme.dividerColor, Colors.white);
    final activeColor = Color.alphaBlend(theme.accentColor, Colors.white);
    final completedColor = Color.alphaBlend(theme.primaryColor, Colors.white);

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: 1,
              valueColor: AlwaysStoppedAnimation<Color>(emptyColor),
            ),
          ),
          if (this.isCurrent)
            AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                value: percentMissed + percentCompleted + (1 / phaseDuration),
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: percentMissed + percentCompleted,
              valueColor: AlwaysStoppedAnimation<Color>(emptyColor),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: percentCompleted,
              valueColor: AlwaysStoppedAnimation<Color>(completedColor),
            ),
          ),
          Stack(
            children: buildSeparators(phaseDuration),
          ),
          RawMaterialButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: InterventionCard(intervention),
                        ));
              },
              elevation: 0,
              fillColor: color,
              shape: CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
              child: interventionIcon(intervention)),
        ],
      ),
    );
  }
}

Iterable<T> intersperseIndexed<T>(T Function(int) generator, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;
  var index = 0;
  if (iterator.moveNext()) {
    yield iterator.current;
    while (iterator.moveNext()) {
      yield generator(index++);
      yield iterator.current;
    }
  }
}
