String getEmojiFlag(String country) {
  final countryUpper = country.toUpperCase();

  const int flagOffset = 0x1F1E6;
  const int asciiOffset = 0x41;

  final int firstChar = countryUpper.codeUnitAt(0) - asciiOffset + flagOffset;
  final int secondChar = countryUpper.codeUnitAt(1) - asciiOffset + flagOffset;

  return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
}
