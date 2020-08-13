import '../models.dart';

abstract class UserStudy {
  String studyId;
  String userId;
  String title;
  String description;
  String iconName;
  DateTime startDate;
  StudySchedule schedule;
  List<String> interventionOrder;
  List<Observation> observations;
  List<ConsentItem> consent;
  Map<String, List<Result>> results;
  ReportSpecification reportSpecification;
}
