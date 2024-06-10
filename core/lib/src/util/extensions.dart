extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    final otherUtc = other.toUtc();
    return toUtc().year == otherUtc.year &&
        toUtc().month == otherUtc.month &&
        toUtc().day == otherUtc.day;
  }

  bool isEarlierDateThan(DateTime other) {
    final otherUtc = other.toUtc();
    if (toUtc().year < otherUtc.year) {
      return true;
    } else if (toUtc().year == otherUtc.year) {
      if (toUtc().month < otherUtc.month) {
        return true;
      } else if (toUtc().month == otherUtc.month) {
        if (toUtc().day < otherUtc.day) {
          return true;
        }
      }
    }
    return false;
  }

  bool isLaterDateThan(DateTime other) {
    return !(toUtc().isSameDate(other.toUtc()) ||
        toUtc().isEarlierDateThan(other.toUtc()));
  }

  int differenceInDays(DateTime other) {
    return toUtc().difference(other.toUtc()).inDays;
  }
}
