// This is used because Exception.toString() always prepends 'Exception: '
class StudyUException implements Exception {
  final String message;

  StudyUException(this.message);

  @override
  String toString() {
    return message;
  }
}