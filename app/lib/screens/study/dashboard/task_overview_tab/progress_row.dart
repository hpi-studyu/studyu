import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../util/intervention.dart';
import '../../onboarding/intervention_card.dart';

class ProgressRow extends StatefulWidget {
  final StudyInstance study;

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
              ...intersperse(divider, widget.study.getInterventionsInOrder().asMap().entries.map((entry) {
                final currentInterventionIndex = widget.study.getInterventionIndexForDate(DateTime.now());
                return
                  InterventionSegment(
                      intervention: entry.value,
                      isCurrent: currentInterventionIndex == entry.key,
                      isFuture: currentInterventionIndex < entry.key);
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
  final bool isCurrent;
  final bool isFuture;

  const InterventionSegment({@required this.intervention, this.isCurrent, this.isFuture, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
        child: Column(
      children: [
        RawMaterialButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        contentPadding: EdgeInsets.all(0),
                        content: InterventionCard(intervention, showCheckbox: false),
                      ));
            },
            elevation: 0,
            fillColor: isCurrent || !isFuture ? theme.accentColor : theme.primaryColor,
            shape: CircleBorder(),
            child: interventionIcon(intervention)),
      ],
    ));
  }
}
