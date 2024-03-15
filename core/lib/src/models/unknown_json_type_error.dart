/// Error thrown when a JSON type is not recognized.
/// This is a subclass of [ArgumentError] because unknown enums also
/// throw an ArgumentError, so we can catch all of them together.
class UnknownJsonTypeError extends ArgumentError {
  final dynamic type;

  UnknownJsonTypeError(this.type);

  @override
  String toString() {
    return 'UnknownJsonTypeError: $type';
  }
}
