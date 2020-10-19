import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study/contact.dart';

class AppState {
  ParseStudy selectedStudy;
  List<Intervention> selectedInterventions;
  ParseUserStudy activeStudy;
  FlutterLocalNotificationsPlugin notificationsPlugin;
  Contact appSupportContact;

  AppState(this.activeStudy);
}
