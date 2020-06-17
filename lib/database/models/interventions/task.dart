typedef TaskParser = Task Function(Map<String, dynamic> data);

abstract class Task {
  static Map<String, TaskParser> taskTypes = {};
  static const String keyType = 'type';
  String type;

  String id;
  String title;

  Task();

  factory Task.fromJson(Map<String, dynamic> data) => taskTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
