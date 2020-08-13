import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../interventions/intervention.dart';
import '../interventions/intervention_set.dart';
import 'study_details.dart';
import 'study_instance.dart';

class ParseStudy extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'Study';

  ParseStudy() : super(_keyTableName);

  ParseStudy.clone() : this();

  @override
  ParseStudy clone(Map<String, dynamic> map) => ParseStudy.clone()..fromJson(map);

  @override
  ParseStudy fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyStudyDetails)) {
      studyDetails = ParseStudyDetails.clone().fromJson(objectData[keyStudyDetails]);
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
  ParseStudyDetails get studyDetails => get<ParseStudyDetails>(keyStudyDetails);
  set studyDetails(ParseStudyDetails studyDetails) => set<ParseStudyDetails>(keyStudyDetails, studyDetails);

  ParseUserStudy extractUserStudy(
      String userId, List<Intervention> selectedInterventions, DateTime startDate, int firstIntervention) {
    final userStudy = ParseUserStudy()
      ..title = title
      ..description = description
      ..iconName = iconName
      ..studyId = id
      ..userId = userId
      ..startDate = startDate
      ..interventionSet = InterventionSet(selectedInterventions)
      ..observations = studyDetails.observations ?? []
      ..reportSpecification = studyDetails.reportSpecification;
    if (studyDetails.schedule != null) {
      const baselineId = '__baseline';
      var addBaseline = false;
      userStudy
        ..schedule = studyDetails.schedule
        ..consent = studyDetails.consent
        ..interventionOrder = studyDetails.schedule.generateWith(firstIntervention).map<String>((index) {
          if (index == null) {
            addBaseline = true;
            return baselineId;
          }
          return selectedInterventions[index].id;
        }).toList();
      if (addBaseline) {
        userStudy.interventionSet = InterventionSet(
            [...userStudy.interventionSet.interventions, Intervention(baselineId, 'Baseline')..tasks = []]);
      }
    } else {
      print('Study is missing schedule or StudyDetails not fetched!');
      return null;
    }
    return userStudy;
  }
}
