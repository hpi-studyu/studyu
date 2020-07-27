import 'package:json_annotation/json_annotation.dart';

part 'outcome.g.dart';

@JsonSerializable()
class Outcome {
  String outcomeId;
  String title;
  String description;

  ChartType chartType;
  ChartX chartX;

  String taskId;
  String questionId;

  Outcome();

  factory Outcome.fromJson(Map<String, dynamic> json) => _$OutcomeFromJson(json);
  Map<String, dynamic> toJson() => _$OutcomeToJson(this);
}

enum ChartType { BAR, LINE }
enum ChartX { DATE, INTERVENTION }
