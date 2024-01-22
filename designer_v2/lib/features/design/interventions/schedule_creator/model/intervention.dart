// part 'intervention.g.dart';
//
// @JsonSerializable()
import 'dart:convert';
import 'dart:math';

class Intervention {
  String id;
  String? name;
  String? description;
  String icon = '';

  // List<InterventionTask> tasks = [];

  Intervention(this.id, this.name);

  Intervention.withId(this.name) : id = randomUUID();
}

// dont use UUID
String randomUUID() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
}