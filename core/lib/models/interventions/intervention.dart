import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'intervention_task.dart';

part 'intervention.g.dart';

@JsonSerializable()
class Intervention {
  String id;
  String name;
  String description;
  String icon;

  List<InterventionTask> tasks;

  Intervention(this.id, this.name);

  Intervention.designer() {
    id = Uuid().v4();
    icon = '';
    tasks = [];
  }

  factory Intervention.fromJson(Map<String, dynamic> data) => _$InterventionFromJson(data);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);
}
