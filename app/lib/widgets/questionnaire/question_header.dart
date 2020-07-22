import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final String prompt;
  final String subtitle;
  final String rationale;

  const QuestionHeader({this.prompt, this.subtitle, this.rationale});

  List<Widget> _buildSubtitle(BuildContext context) {
    if (subtitle == null) return [];
    return [
      SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.caption),
    ];
  }

  List<Widget> _buildRationaleButton(BuildContext context) {
    if (rationale == null) return [];
    return [
      SizedBox(width: 8),
      IconButton(
        icon: Icon(Icons.info_outline),
        color: Theme.of(context).primaryColor,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Information'),
            content: Text(rationale),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prompt, style: Theme.of(context).textTheme.subtitle1),
              ..._buildSubtitle(context),
            ],
          ),
        ),
        ..._buildRationaleButton(context),
      ],
    );
  }
}
