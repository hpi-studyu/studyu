class DesignerModel {
  LocalStudy draftStudy;

  DesignerModel() {
    final studyDetails = LocalStudyDetails()
      ..interventions = []
      ..eligibilityQuestionnaire = [];

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
  List<LocalQuestion> eligibilityQuestionnaire;
}

class LocalIntervention {
  String name;
  String description;
  List<LocalTask> tasks;
}

class LocalTask {
  String name;
  String description;
  int hour;
  int minute;
}

class LocalCheckMarkTask extends LocalTask {}

class LocalQuestion {
  String question;
  String excludingAnswer;
  String excludingAnswerReason;
}
