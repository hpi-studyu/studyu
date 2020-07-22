import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Widget _buildInterventionSegment(BuildContext context, Intervention intervention, bool isCurrent, bool isFuture) {
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
                        content: isBaseline(intervention)
                            ? BaselineCard()
                            : InterventionCard(intervention, showCheckbox: false),
                      ));
            },
            elevation: 0,
            fillColor: isCurrent || !isFuture ? theme.accentColor : theme.primaryColor,
            shape: CircleBorder(),
            child: interventionIcon(intervention)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              ...widget.study.getInterventionsInOrder().asMap().entries.map((entry) {
                final currentInterventionIndex = widget.study.getInterventionIndexForDate(DateTime.now());
                return _buildInterventionSegment(
                    context, entry.value, currentInterventionIndex == entry.key, currentInterventionIndex < entry.key);
              }),
              Icon(MdiIcons.flagCheckered, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class BaselineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(MdiIcons.rayStart),
          dense: true,
          title: Text(
            'Baseline',
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'A baseline study is an analysis of the current situation to identify the starting points for a programme or project. It looks at what information must be considered and analyzed to establish a baseline or starting point, the benchmark against which future progress can be assessed or comparisons made.',
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        )
      ],
    );
  }
}
