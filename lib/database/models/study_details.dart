import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'intervention.dart';

class StudyDetails extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'StudyDetails';
  static const keyInterventions = 'interventions';

  StudyDetails() : super(_keyTableName);

  StudyDetails.clone() : this();

  @override
  StudyDetails clone(Map<String, dynamic> map) => StudyDetails.clone()..fromJson(map);

  List<Intervention> get eligibility =>
      get<List<dynamic>>(keyInterventions)?.map((e) => Intervention.fromJson(e))?.toList() ?? [];

  set eligibility(List<Intervention> eligibility) =>
      set<List<Map<String, dynamic>>>(keyInterventions, eligibility.map((e) => e.toJson()).toList());
}
