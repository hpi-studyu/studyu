import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/report/sections/linear_regression_section.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';
import 'package:uuid/uuid.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static const String keyType = 'type';
  String type;
  late String id;
  String? title;
  String? description;

  ReportSection(this.type);

  ReportSection.withId(this.type) : id = const Uuid().v4();

  factory ReportSection.fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
        AverageSection.sectionType => AverageSection.fromJson(data),
        LinearRegressionSection.sectionType => LinearRegressionSection.fromJson(data),
        _ => throw UnknownJsonTypeError(data[keyType]),
      };
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
