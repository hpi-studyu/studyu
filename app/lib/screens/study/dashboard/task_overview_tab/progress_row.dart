import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
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

    final divider = Expanded(
      child: Divider(
        indent: 5,
        endIndent: 5,
        thickness: 3,
        color: theme.primaryColor,
      ),
    );

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
              ...intersperse(
                  divider,
                  widget.study.getInterventionsInOrder().asMap().entries.map((entry) {
                    return InterventionSegment(
                      intervention: entry.value,
                      isCurrent: currentPhase == entry.key,
                      isFuture: currentPhase < entry.key,
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

  const InterventionSegment(
      {@required this.intervention,
      @required this.percentCompleted,
      @required this.percentMissed,
      @required this.isCurrent,
      @required this.isFuture,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFuture ? Colors.grey : (isCurrent ? theme.accentColor : theme.primaryColor);

    return Expanded(
        child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: percentMissed + percentCompleted,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
        CircularProgressIndicator(
          value: percentCompleted,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
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
    ));
  }
}
