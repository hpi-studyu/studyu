import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'interventions/intervention_set.dart';

class UserStudy extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'UserStudy';

  UserStudy() : super(_keyTableName);

  UserStudy.clone() : this();

  @override
  UserStudy clone(Map<String, dynamic> map) => UserStudy.clone()..fromJson(map);

  static const keyStudyId = 'study_id';
  String get studyId => get<String>(keyStudyId);
  set studyId(String studyId) => set<String>(keyStudyId, studyId);

  static const keyUserId = 'user_id';
  String get userId => get<String>(keyUserId);
  set userId(String userId) => set<String>(keyUserId, userId);

  static const keyTitle = 'title';
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';
  String get iconName => get<String>(keyIconName);
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyInterventionOrder = 'intervention_order';
  List<int> get interventionOrder => get<List<dynamic>>(keyInterventionOrder);
  set interventionOrder(List<int> interventionOrder) => set<List<int>>(keyInterventionOrder, interventionOrder);

  static const keyInterventionSet = 'intervention_set';
  InverventionSet get interventionSet => InverventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InverventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
}
