import 'package:uuid/uuid.dart';

import 'sections/average_section.dart';
import 'sections/linear_regression_section.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static Map<String, SectionParser> sectionTypes = {
    AverageSection.sectionType: (json) => AverageSection.fromJson(json),
    LinearRegressionSection.sectionType: (json) => LinearRegressionSection.fromJson(json),
  };
  static const String keyType = 'type';
  String/*!*/ type;
  String/*!*/ id;
  String title;
  String description;

  ReportSection(this.type);

  ReportSection.designer(this.type) : id = Uuid().v4();

  factory ReportSection.fromJson(Map<String, dynamic> data) => sectionTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
