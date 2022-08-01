
extension EnumX on Enum {
  String toShortString() {
    return toString().split('.').last;
  }
}
