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
