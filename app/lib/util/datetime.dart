bool isBeforeDay(DateTime a, DateTime b) {
  final numA = "${a.year}${a.month}${a.day}";
  final numB = "${b.year}${b.month}${b.day}";

  return int.parse(numA) < int.parse(numB);
}
