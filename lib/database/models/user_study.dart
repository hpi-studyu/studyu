import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'eligibility/eligibility_criterion.dart';
import 'interventions/intervention_set.dart';
import 'questionnaire/questionnaire.dart';

class UserStudy extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'UserStudy';
  UserStudy() : super(_keyTableName);
  UserStudy.clone() : this();

  @override
  UserStudy clone(Map<String, dynamic> map) => UserStudy.clone()..fromJson(map);

  static const keyTitle = 'title';
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';
  String get iconName => get<String>(keyIconName);
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyInterventionOrder = 'interventionOrder';
  List<int> get interventionOrder => get<List<dynamic>>(keyInterventionOrder);
  set interventionOrder(List<int> interventionOrder) => set<List<int>>(keyInterventionOrder, interventionOrder);

  static const keyEligibility = 'eligibilityCriteria';
  List<EligibilityCriterion> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => EligibilityCriterion.fromJson(e))?.toList() ?? [];
  set eligibility(List<EligibilityCriterion> eligibility) =>
      set<List<dynamic>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  static const keyInterventionSet = 'interventionSet';
  InverventionSet get interventionSet => InverventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InverventionSet interventionSet) => set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
}
