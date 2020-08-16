class StudyBase {
  String id;
  String title;
  String description;
  String iconName;

  StudyBase toBase() {
    return StudyBase()
      ..id = id
      ..title = title
      ..description = description
      ..iconName = iconName;
  }
}
