import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../database/models/intervention.dart';

class ProgressRow extends StatefulWidget {
  final List<Intervention> plannedInterventions;

  const ProgressRow({Key key, this.plannedInterventions}) : super(key: key);
  @override
  _ProgressRowState createState() => _ProgressRowState();
}

class _ProgressRowState extends State<ProgressRow> {
  Widget _buildInterventionSegment(BuildContext context, Intervention intervention, bool isCurrent) {
    final theme = Theme.of(context);
    return Expanded(
        child: Column(
      children: [
        RawMaterialButton(
          padding: isCurrent ? EdgeInsets.all(10) : EdgeInsets.all(0),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('$Intervention: ${intervention.name}'),
                    ));
          },
          elevation: 0,
          fillColor: isCurrent ? theme.accentColor : theme.primaryColor,
          child: Icon(
            intervention.name == 'Exercise' ? MdiIcons.dumbbell : MdiIcons.pill,
            color: Colors.white,
            size: 18,
          ),
          shape: CircleBorder(),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(
            color: theme.accentColor,
            thickness: 8,
            indent: 34,
            endIndent: 34,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.run, size: 30),
              SizedBox(width: 8),
              ...widget.plannedInterventions.asMap().entries.map((entry) {
                // mock one active intervention week
                final idx = entry.key;
                return _buildInterventionSegment(context, entry.value, idx == 1);
              }),
              SizedBox(width: 8),
              Icon(MdiIcons.flagCheckered, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}
