enum DateFormatPreset {
  isoDate('yyyy-MM-dd'), // 2024-12-31
  europeanDate('dd/MM/yyyy'), // 31/12/2024
  usDate('MM/dd/yyyy'), // 12/31/2024
  germanDate('dd.MM.yyyy'), // 31.12.2024
  isoDateTime('yyyy-MM-dd HH:mm'), // 2024-12-31 14:30
  europeanDateTime('dd/MM/yyyy HH:mm'), // 31/12/2024 14:30
  usDateTimeAmPm('MM/dd/yyyy hh:mm a'); // 12/31/2024 02:30 PM

  final String pattern;
  const DateFormatPreset(this.pattern);

  bool get includesTime => pattern.contains('H') || pattern.contains('h');

  String toJson() => name;
  static DateFormatPreset fromJson(String json) => values.byName(json);
}
