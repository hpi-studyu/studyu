import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final String prompt;
  final String subtitle;
  final String rationale;

  const QuestionHeader({this.prompt, this.subtitle, this.rationale});

  List<Widget> _buildSubtitle(BuildContext context) {
    if (subtitle == null) return [];
    return [
      const SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ];
  }

  List<Widget> _buildRationaleButton(BuildContext context) {
    if (rationale == null) return [];
    return [
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.info_outline),
        color: Theme.of(context).primaryColor,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Information'),
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
              Text(prompt, style: Theme.of(context).textTheme.titleMedium),
              ..._buildSubtitle(context),
            ],
          ),
        ),
        ..._buildRationaleButton(context),
      ],
    );
  }
}
