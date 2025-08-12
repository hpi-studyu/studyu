bool isRedundantClick(
  DateTime? lastClickTime, {
  Duration interval = const Duration(seconds: 1),
}) {
  if (lastClickTime == null) return false;
  final now = DateTime.now();
  if (now.difference(lastClickTime) > interval) {
    return false;
  }
  return true;
}
