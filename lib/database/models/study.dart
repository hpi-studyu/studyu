import 'package:parse_server_sdk/parse_server_sdk.dart';

/*
import 'condition.dart';
import 'intervention.dart';*/
import 'questions/question.dart';

class Study extends ParseObject implements ParseCloneable {

  static const _keyTableName = 'Study';
  static const keyId = 'study_id';
  static const keyTitle = 'title';
  static const keyDescription = 'description';
  static const keyEligibility = 'eligibility';

  /*List<Question> eligibility = [];
  List<Condition> conditions = [];
  List<Intervention> interventions = [];*/

  Study() : super(_keyTableName);

  Study.clone() : this();

  @override
  Study clone(Map<String, dynamic> map)  => Study.clone()..fromJson(map);

  String get id => get<String>(keyId);
  set id(String id) => set<String>(keyId, id);
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);
  List<Question> get eligibility => get<List<dynamic>>(keyEligibility)?.map((e) => Question.fromJson(e))?.toList() ?? [];
  set eligibility(List<Question> eligibility) => set<List<Map<String, dynamic>>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  @override
  String toString() {
    return 'Study(id = $id, title = $title, description = $description, eligibility = $eligibility)';
  }
}
