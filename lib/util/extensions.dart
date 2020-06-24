extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isEarlierDateThan(DateTime other) {
    if (year < other.year) {
      return true;
    } else if (year == other.year) {
      if (month < other.month) {
        return true;
      } else if (month == other.month) {
        if (day < other.day) {
          return true;
        }
      }
    }
    return false;
  }

  bool isLaterDateThan(DateTime other) {
    return !(isSameDate(other) || isEarlierDateThan(other));
  }

  Duration differenceInDays(DateTime other) {
    final currentZero = DateTime(year, month, day);
    final otherZero = DateTime(other.year, other.month, other.day);
    return currentZero.difference(otherZero);
  }
}
