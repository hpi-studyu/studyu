import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

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
          padding: isCurrent ? EdgeInsets.all(15) : EdgeInsets.all(5),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('$Intervention: ${intervention.name}'),
                    ));
          },
          elevation: 0,
          fillColor: isCurrent || !isFuture ? theme.accentColor : theme.primaryColor,
          shape: CircleBorder(),
          child: Text(intervention.name[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
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
