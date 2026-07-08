enum DateInputType {
  date('date'),
  time('time'),
  dateTime('dateTime');

  final String value;
  const DateInputType(this.value);

  bool get isDate =>
      this == DateInputType.date || this == DateInputType.dateTime;
  bool get isTime =>
      this == DateInputType.time || this == DateInputType.dateTime;

  String toJson() => value;
  static DateInputType fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => DateInputType.date,
  );
}
