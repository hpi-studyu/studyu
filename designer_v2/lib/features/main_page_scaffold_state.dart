import 'package:flutter/material.dart';

// Regional indicator symbols based on ISO 3166-1
enum Regional {
  us,
  de,
  qu,
}

class Localization {
  final Regional regional;
  final String displayName;

  Localization({required this.regional, required this.displayName});

  static final english = Localization(regional: Regional.us, displayName: "English");
  static final german =  Localization(regional: Regional.de, displayName: "German");
  static final quenya =  Localization(regional: Regional.qu, displayName: "Quenya"); // testing

  static List<Localization> get values => [english, german, quenya];
}

class MainPageState {
  final Localization defaultLocalization = Localization.english;
  late Localization selectedLocalization;

  List<DropdownMenuItem<Localization>> get dropdownItems{
    return Localization.values.map((localization) =>
        DropdownMenuItem(value: localization, child: Text('${_emojiFlag(localization.regional.name)} ${localization.displayName}'), )
    ).toList();
  }

  // Emoji flag sequences
  String _emojiFlag(String country) {
    country = country.toUpperCase();

    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}
