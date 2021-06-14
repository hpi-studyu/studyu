extension ID on String {
  String toId() => toLowerCase().replaceAll(RegExp(r'\s+'), '_');
}
