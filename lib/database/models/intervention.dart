class Intervention {
  
  String name;

  Intervention(this.name);

  Intervention.fromJson(Map<String, dynamic> data) {
    name = data['name'];
  }

  Map<String, dynamic> toJson() => {
    'name': name
  };

}