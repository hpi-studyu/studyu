extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isEarlierDateThan(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    if (a.year != b.year) return a.year < b.year;
    if (a.month != b.month) return a.month < b.month;
    return a.day < b.day;
  }

  bool isLaterDateThan(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    return !(a.isSameDate(b) || a.isEarlierDateThan(b));
  }

  int differenceInDays(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    return a.difference(b).inDays;
  }
}
