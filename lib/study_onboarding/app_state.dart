import 'package:nof1_models/models/models.dart';

class AppModel {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudyInstance activeStudy;

  AppModel(this.activeStudy);
}
