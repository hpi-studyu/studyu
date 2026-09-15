enum DefaultDateOption {
  none('none'),
  today('today'),
  now('now'),
  specific('specific');

  final String value;
  const DefaultDateOption(this.value);

  String toJson() => value;
  static DefaultDateOption fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => DefaultDateOption.none,
  );
}
