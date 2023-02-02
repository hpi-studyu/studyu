import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/report/sections/linear_regression_section.dart';
import 'package:uuid/uuid.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static Map<String, SectionParser> sectionTypes = {
    AverageSection.sectionType: (json) => AverageSection.fromJson(json),
    LinearRegressionSection.sectionType: (json) => LinearRegressionSection.fromJson(json),
  };
  static const String keyType = 'type';
  String type;
  late String id;
  String? title;
  String? description;

  ReportSection(this.type);

  ReportSection.withId(this.type) : id = const Uuid().v4();

  factory ReportSection.fromJson(Map<String, dynamic> data) => sectionTypes[data[keyType]]!(data);
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
