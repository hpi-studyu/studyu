import '../database/models/models.dart';
import '../database/models/user_study.dart';

class AppModel {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  UserStudy userStudy;

  AppModel(this.userStudy);
}
