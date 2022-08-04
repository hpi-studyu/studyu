import 'package:studyu_designer_v2/constants.dart';

extension EnumX on Enum {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringX on String {
  bool get isNewId => this == Config.newModelId;

  String asId() {
    return toLowerCase().replaceAll(' ', '_');
  }

  String withDuplicateLabel({label=kDuplicateLabel}) {
    final regexStr = r"\((?:" + label + r")\s*(\d*)\)$";
    final suffixFactory = (n) => (n > 0) ? "($label ${n.toString()})" : "($label)";
    final regex = RegExp(regexStr);

    Iterable<RegExpMatch> matches = regex.allMatches(this);

    if (matches.isNotEmpty) {
      final matchedSuffix = matches.last;
      final matchedIncrement = matchedSuffix.group(1);
      final currentIncrement = (matchedIncrement == null
          || matchedIncrement == '') ? 0 : int.parse(matchedIncrement);
      final strWithoutLabel = replaceRange(
          matchedSuffix.start, matchedSuffix.end, '').trim();
      return "$strWithoutLabel ${suffixFactory(currentIncrement + 1)}";
    }
    return "${this} ${suffixFactory(0)}";
  }
}
