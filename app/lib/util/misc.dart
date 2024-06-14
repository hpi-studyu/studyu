bool isRedundantClick(
  DateTime lastClickTime, {
  Duration interval = const Duration(seconds: 2),
}) {
  final now = DateTime.now();
  if (now.difference(lastClickTime) > interval) {
    return false;
  }
  return true;
}
