import 'intervention.dart';

class InverventionSet {
  static const String keyInterventions = 'interventions';
  List<Intervention> interventions;

  InverventionSet.fromJson(Map<String, dynamic> data) {
    interventions = data[keyInterventions].map<Intervention>((entry) => Intervention.fromJson(entry)).toList();
  }

  Map<String, dynamic> toJson() => {
    keyInterventions: interventions.map((intervention) => intervention.toJson()).toList()
  };
}
