import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'interventions/intervention.dart';
import 'interventions/intervention_set.dart';
import 'study_details.dart';
import 'study_instance.dart';

class Study extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'Study';

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

  static const keyId = 'study_id';

  String get id => get<String>(keyId);

  set id(String id) => set<String>(keyId, id);

  static const keyTitle = 'title';

  String get title => get<String>(keyTitle);

  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';

  String get description => get<String>(keyDescription);

  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';

  String get iconName => get<String>(keyIconName);

  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyStudyDetails = 'study_details';

  StudyDetails get studyDetails => get<StudyDetails>(keyStudyDetails);

  set studyDetails(StudyDetails studyDetails) => set<StudyDetails>(keyStudyDetails, studyDetails);

  StudyInstance extractUserStudy(String userId, List<Intervention> selectedInterventions, int firstIntervention) {
    final userStudy = StudyInstance()
      ..title = title
      ..description = description
      ..studyId = id
      ..userId = userId
      ..interventionSet = InverventionSet(selectedInterventions)
      ..observations = studyDetails.observations;
    if (studyDetails.schedule != null) {
      userStudy.interventionOrder = studyDetails.schedule.generateWith(firstIntervention);
    } else {
      print('Study is missing schedule or StudyDetails not fetched!');
      return null;
    }
    return userStudy;
  }
}
