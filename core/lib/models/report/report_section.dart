import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static Map<String, SectionParser> sectionTypes = {
    AverageSection.sectionType: (json) => AverageSection.fromJson(json),
  };
  static const String keyType = 'type';
  String type;
  String id;
  String title;
  String description;

  ReportSection(this.type);

  ReportSection.designer(this.type) : id = Uuid().v4();

  factory ReportSection.fromJson(Map<String, dynamic> data) => sectionTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
