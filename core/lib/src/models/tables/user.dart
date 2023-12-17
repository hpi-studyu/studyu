import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';

part 'user.g.dart';

@JsonSerializable()
class StudyUUser extends SupabaseObjectFunctions<StudyUUser> {
  static const String tableName = 'user';

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'email')
  String email;
  @JsonKey(name: 'preferences')
  Preferences preferences;

  StudyUUser({required this.id, required this.email, Preferences? preferences})
      : preferences = preferences ?? Preferences();

  factory StudyUUser.fromJson(Map<String, dynamic> json) => _$StudyUUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyUUserToJson(this);
}

@JsonSerializable()
class Preferences {
  // todo store preferred user language in database
  @JsonKey(name: 'lang')
  String language;

  @JsonKey(name: 'pinned_studies')
  Set<String> pinnedStudies;

  Preferences({this.language = '', this.pinnedStudies = const {}});

  factory Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$PreferencesToJson(this);
    // Remove empty fields from the JSON map
    json.removeWhere(
      (key, value) => value == null || value is String && value.isEmpty || value is Set && value.isEmpty,
    );
    return json;
  }
}
