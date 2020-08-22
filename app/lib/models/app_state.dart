import 'package:studyou_core/models/models.dart';

class AppState {
  ParseStudy selectedStudy;
  List<Intervention> selectedInterventions;
  ParseUserStudy activeStudy;

  AppState(this.activeStudy);
}
