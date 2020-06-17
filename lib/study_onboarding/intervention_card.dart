import 'package:flutter/material.dart';

import '../database/models/interventions/intervention.dart';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final Function() onTap;

  const InterventionCard(this.intervention, {this.onTap, this.selected = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: onTap,
          trailing: Checkbox(
            value: selected,
            onChanged: null,
          ),
          dense: true,
          title: Text(
            intervention.name,
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Some description that is now on another section. How bout that. It even takes up all the horizontal space.',
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Daily Tasks:'),
        ),
        Divider(
          height: 4,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 2,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: Text('Drink tea')),
                FittedBox(
                    child: Text(
                  '18:00',
                  style: theme.textTheme.bodyText2.copyWith(fontSize: 12, color: theme.textTheme.caption.color),
                )),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
