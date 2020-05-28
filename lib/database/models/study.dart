import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'questionnaire/conditions/condition.dart';
import 'questionnaire/questions/question.dart';
import 'study_details.dart';

class Study extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'Study';
  static const keyId = 'study_id';
  static const keyTitle = 'title';
  static const keyDescription = 'description';
  static const keyEligibility = 'eligibility';
  static const keyConditions = 'conditions';
  static const keyIconName = 'icon_name';
  static const keyStudyDetails = 'study_details';

  /*List<Question> eligibility = [];
  List<Condition> conditions = [];
  List<Intervention> interventions = [];*/

  Study() : super(_keyTableName);

  Study.clone() : this();

  @override
  Study clone(Map<String, dynamic> map) => Study.clone()..fromJson(map);

  @override
  Study fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyStudyDetails)) {
      studyDetails = StudyDetails.clone().fromJson(objectData[keyStudyDetails]);
    }
    return this;
  }

  String get id => get<String>(keyId);
  set id(String id) => set<String>(keyId, id);
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);
  String get iconName => get<String>(keyIconName);
  set iconName(String iconName) => set<String>(keyIconName, iconName);
  List<Question> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => Question.fromJson(e))?.toList() ?? [];
  set eligibility(List<Question> eligibility) =>
      set<List<Map<String, dynamic>>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());
  List<Condition> get conditions =>
      get<List<dynamic>>(keyConditions)?.map((e) => Condition.fromJson(e))?.toList() ?? [];
  set conditions(List<Condition> conditions) =>
      set<List<Map<String, dynamic>>>(keyConditions, conditions.map((e) => e.toJson()).toList());
  StudyDetails get studyDetails => get<StudyDetails>(keyStudyDetails);
  set studyDetails(StudyDetails studyDetails) => set<StudyDetails>(keyStudyDetails, studyDetails);
}
