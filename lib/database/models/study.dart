import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'study_details.dart';

class Study extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'Study';
  static const keyId = 'study_id';
  static const keyTitle = 'title';
  static const keyDescription = 'description';
  static const keyIconName = 'icon_name';

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

  static const keyStudyDetails = 'study_details';
  StudyDetails get studyDetails => get<StudyDetails>(keyStudyDetails);
  set studyDetails(StudyDetails studyDetails) => set<StudyDetails>(keyStudyDetails, studyDetails);
}
