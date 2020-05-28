import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'intervention.dart';

class StudyDetails extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'StudyDetails';
  static const keyInterventions = 'interventions';

  StudyDetails() : super(_keyTableName);

  StudyDetails.clone() : this();

  @override
  StudyDetails clone(Map<String, dynamic> map) => StudyDetails.clone()..fromJson(map);

  List<Intervention> get interventions =>
      get<List<dynamic>>(keyInterventions)?.map((e) => Intervention.fromJson(e))?.toList() ?? [];

  set interventions(List<Intervention> interventions) =>
      set<List<Map<String, dynamic>>>(keyInterventions, interventions.map((e) => e.toJson()).toList());
}
