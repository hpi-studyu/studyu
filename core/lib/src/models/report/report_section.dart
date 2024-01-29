import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/report/sections/linear_regression_section.dart';
import 'package:studyu_core/src/models/report/sections/unknown_section.dart';
import 'package:uuid/uuid.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static const String keyType = 'type';
  String type;
  late String id;
  String? title;
  String? description;

  bool get isSupported => true;

  ReportSection(this.type);

  ReportSection.withId(this.type) : id = const Uuid().v4();

  factory ReportSection.fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
        AverageSection.sectionType => AverageSection.fromJson(data),
        LinearRegressionSection.sectionType => LinearRegressionSection.fromJson(data),
        _ => UnknownSection(),
      };
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
