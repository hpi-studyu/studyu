import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

Map<String, int> getInterventionPositions(List<Intervention> interventions) {
  final order = <String, int>{};
  if (interventions.any((intervention) => intervention.id == Study.baselineID)) {
    order[Study.baselineID] = 0;
    interventions.removeWhere((intervention) => intervention.id == Study.baselineID);
  }
  order[interventions.first.id] = 1;
  order[interventions.last.id] = 2;
  return order;
}

class LegendWidget extends StatelessWidget {
  LegendWidget({
    super.key,
    required Legend legend,
  })  : name = legend.name,
        color = legend.color;

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class LegendsListWidget extends StatelessWidget {
  const LegendsListWidget({
    super.key,
    required this.legends,
  });
  final List<Legend> legends;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: legends.map((legend) => LegendWidget(legend: legend)).toList(),
    );
  }
}

class Legend {
  Legend(this.name, this.color);
  final String name;
  final Color color;
}
