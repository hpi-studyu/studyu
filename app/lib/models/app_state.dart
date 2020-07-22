import 'package:studyou_core/models/models.dart';

class AppModel {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudyInstance activeStudy;
  StudyInstance reportStudy;

  AppModel(this.activeStudy);
}
