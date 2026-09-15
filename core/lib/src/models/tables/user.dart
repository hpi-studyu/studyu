import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';

part 'user.g.dart';

enum DateFormatPreference {
  @JsonValue('iso')
  iso('yyyy-MM-dd'),
  @JsonValue('european')
  european('dd/MM/yyyy'),
  @JsonValue('us')
  us('MM/dd/yyyy'),
  @JsonValue('german')
  german('dd.MM.yyyy');

  const DateFormatPreference(this.pattern);

  final String pattern;
}

enum TimeFormatPreference {
  @JsonValue('h24')
  h24('HH:mm'),
  @JsonValue('h12')
  h12('h:mm a');

  const TimeFormatPreference(this.pattern);

  final String pattern;
}

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

  factory StudyUUser.fromJson(Map<String, dynamic> json) =>
      _$StudyUUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyUUserToJson(this);
}

@JsonSerializable()
class Preferences {
  // todo store preferred user language in database
  @JsonKey(name: 'lang')
  String language;

  @JsonKey(name: 'date_format')
  DateFormatPreference? dateFormat;

  @JsonKey(name: 'time_format')
  TimeFormatPreference? timeFormat;

  @JsonKey(name: 'pinned_studies')
  Set<String> pinnedStudies;

  @JsonKey(name: 'study_filtering')
  Map<String, dynamic> studyFiltering;

  Preferences({
    this.language = '',
    this.dateFormat,
    this.timeFormat,
    this.pinnedStudies = const {},
    this.studyFiltering = const {},
  });

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$PreferencesToJson(this);
    // Remove empty fields from the JSON map
    json.removeWhere(
      (key, value) =>
          value == null ||
          value is String && value.isEmpty ||
          value is Set && value.isEmpty,
    );
    return json;
  }
}
