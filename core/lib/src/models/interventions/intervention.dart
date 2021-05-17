import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'intervention_task.dart';

part 'intervention.g.dart';

@JsonSerializable()
class Intervention {
  String id;
  String? name;
  String? description;
  String icon = '';

  List<InterventionTask> tasks = [];

  Intervention(this.id, this.name);

  Intervention.withId() : id = Uuid().v4();

  factory Intervention.fromJson(Map<String, dynamic> data) => _$InterventionFromJson(data);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);

  bool isBaseline() => name == 'Baseline';
}
