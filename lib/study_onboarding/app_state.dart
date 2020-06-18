import '../database/models/models.dart';
import '../database/models/study_instance.dart';

class AppModel {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudyInstance activeStudy;

  AppModel(this.activeStudy);
}
