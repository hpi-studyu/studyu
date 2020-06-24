import 'package:json_annotation/json_annotation.dart';

import 'observation_task.dart';

part 'observation.g.dart';

@JsonSerializable()
class Observation {
  String id;
  String name;

  List<ObservationTask> tasks;

  Observation(this.id, this.name);

  factory Observation.fromJson(Map<String, dynamic> data) => _$ObservationFromJson(data);

  Map<String, dynamic> toJson() => _$ObservationToJson(this);
}
