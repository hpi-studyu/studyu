class DesignerModel {
  LocalStudy draftStudy;

  DesignerModel() {
    final studyDetails = LocalStudyDetails()..interventions = [];

    draftStudy = LocalStudy()
      ..title = ''
      ..description = ''
      ..studyDetails = studyDetails;
  }
}

class LocalStudy {
  String title;
  String description;
  LocalStudyDetails studyDetails;
}

class LocalStudyDetails {
  List<LocalIntervention> interventions;
}

class LocalIntervention {
  String name;
  String description;
  List<LocalTask> tasks;
}

class LocalTask {
  String name;
  String description;
  List<LocalSchedule> schedules;
}

class LocalCheckMarkTask extends LocalTask {}

class LocalSchedule {}

class LocalFixedSchedule extends LocalSchedule {
  int hour;
  int minute;
}
