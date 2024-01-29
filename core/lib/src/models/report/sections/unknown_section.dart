import 'package:studyu_core/src/models/report/report_section.dart';

class UnknownSection extends ReportSection {
  static const String sectionType = 'unknown';

  UnknownSection() : super(sectionType);

  @override
  bool get isSupported => false;

  @override
  Map<String, dynamic> toJson() {
    throw ArgumentError('UnknownSection should not be serialized');
  }
}
