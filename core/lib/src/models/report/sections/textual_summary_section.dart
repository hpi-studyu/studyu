import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'textual_summary_section.g.dart';

@JsonSerializable()
class TextualSummarySection extends ReportSection {
  static const String sectionType = 'textual_summary';

  DataReference<num>? resultProperty;

  TextualSummarySection() : super(sectionType);

  TextualSummarySection.withId() : super.withId(sectionType);

  factory TextualSummarySection.fromJson(Map<String, dynamic> json) =>
      _$TextualSummarySectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TextualSummarySectionToJson(this);
}
