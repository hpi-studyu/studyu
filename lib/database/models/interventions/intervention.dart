class Intervention {
  static const String keyID = "id";
  String id;

  static const String keyName = "name";
  String name;

  Intervention(this.name);

  Intervention.fromJson(Map<String, dynamic> data) {
    id = data[keyID];
    name = data[keyName];
  }

  Map<String, dynamic> toJson() => {
    keyID: id,
    keyName: name
  };
}
