typedef SectionParser = Section Function(Map<String, dynamic> data);

abstract class Section {
  static Map<String, SectionParser> sectionTypes = {};
  static const String keyType = 'type';
  String type;

  String id;
  String title;
  String description;

  Section(this.type);

  factory Section.fromJson(Map<String, dynamic> data) {
    return sectionTypes[data[keyType]](data);
  }
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}
