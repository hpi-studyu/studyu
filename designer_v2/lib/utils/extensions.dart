import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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

extension DateTimeAgoX on DateTime {
  String toTimeAgoString() {
    Duration diff = DateTime.now().difference(this);
    if (diff.inDays >= 1) {
      return '${diff.inDays} tr.days_ago' ;
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} tr.hours_ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} tr.minutes_ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} tr.seconds_ago';
    } else {
      return tr.just_now;
    }
  }
}
