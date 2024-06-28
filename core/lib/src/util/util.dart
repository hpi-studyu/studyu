export 'extensions.dart';
export 'multimodal/blob_storage_handler.dart';
export 'supabase_object.dart';

/// Returns true if [a] is before [b] in terms of year, month and day
bool isBeforeDay(DateTime a, DateTime b) {
  final numA = "${a.year}${pad(a.month)}${pad(a.day)}";
  final numB = "${b.year}${pad(b.month)}${pad(b.day)}";

  print("numA: $numA, numB: $numB");
  return int.parse(numA) < int.parse(numB);
}

String pad(int number, {int length = 2}) {
  return number.toString().padLeft(length, '0');
}
