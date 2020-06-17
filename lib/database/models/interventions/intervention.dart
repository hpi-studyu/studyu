import 'package:json_annotation/json_annotation.dart';

import 'task.dart';

part 'intervention.g.dart';

@JsonSerializable()
class Intervention {
  String id;
  String name;

  List<Task> tasks;

  Intervention(this.id, this.name);

  factory Intervention.fromJson(Map<String, dynamic> data) => _$InterventionFromJson(data);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);
}
