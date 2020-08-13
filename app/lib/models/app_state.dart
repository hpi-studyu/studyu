import 'package:studyou_core/models/models.dart';

class AppModel {
  ParseStudy selectedStudy;
  List<Intervention> selectedInterventions;
  ParseUserStudy activeStudy;

  AppModel(this.activeStudy);
}
