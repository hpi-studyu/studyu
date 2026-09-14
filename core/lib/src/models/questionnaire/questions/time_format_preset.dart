enum TimeFormatPreset {
  h24('HH:mm'),
  h12('hh:mm a');

  final String pattern;
  const TimeFormatPreset(this.pattern);

  bool get is24Hour => this == TimeFormatPreset.h24;

  String toJson() => name;
  static TimeFormatPreset fromJson(String json) {
    // Backward compatibility - default to h24 if unknown
    try {
      return values.byName(json);
    } catch (_) {
      return h24;
    }
  }
}
