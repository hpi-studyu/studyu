import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

enum DateFormatPreference {
  iso('yyyy-MM-dd'),
  european('dd/MM/yyyy'),
  us('MM/dd/yyyy'),
  german('dd.MM.yyyy');

  const DateFormatPreference(this.pattern);

  final String pattern;
}

enum TimeFormatPreference {
  h24('HH:mm'),
  h12('h:mm a');

  const TimeFormatPreference(this.pattern);

  final String pattern;
}

class DateTimePreferences extends ChangeNotifier {
  static const _dateFormatKey = 'date_format';
  static const _timeFormatKey = 'time_format';

  DateFormatPreference? _dateFormat;
  TimeFormatPreference? _timeFormat;

  DateTimePreferences() {
    _load();
  }

  DateFormatPreference? get dateFormat => _dateFormat;
  TimeFormatPreference? get timeFormat => _timeFormat;

  Future<void> _load() async {
    final dateFormat = await SecureStorage.read(_dateFormatKey);
    final timeFormat = await SecureStorage.read(_timeFormatKey);
    _dateFormat = _parseDateFormat(dateFormat);
    _timeFormat = _parseTimeFormat(timeFormat);
    notifyListeners();
  }

  Future<void> changeDateFormat(DateFormatPreference? value) async {
    _dateFormat = value;
    await _writeOrDelete(_dateFormatKey, value?.name);
    notifyListeners();
  }

  Future<void> changeTimeFormat(TimeFormatPreference? value) async {
    _timeFormat = value;
    await _writeOrDelete(_timeFormatKey, value?.name);
    notifyListeners();
  }

  String formatDate(BuildContext context, DateTime date) {
    final preference = _dateFormat;
    if (preference == null) {
      return MaterialLocalizations.of(context).formatCompactDate(date);
    }

    return DateFormat(preference.pattern).format(date);
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    final preference = _timeFormat;
    if (preference == null) return time.format(context);

    return DateFormat(
      preference.pattern,
      Localizations.localeOf(context).toString(),
    ).format(DateTime(2000, 1, 1, time.hour, time.minute));
  }

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return '${formatDate(context, dateTime)} ${formatTime(context, TimeOfDay.fromDateTime(dateTime))}';
  }

  DateFormatPreference? _parseDateFormat(String? value) {
    if (value == null) return null;
    return DateFormatPreference.values
        .where((item) => item.name == value)
        .firstOrNull;
  }

  TimeFormatPreference? _parseTimeFormat(String? value) {
    if (value == null) return null;
    return TimeFormatPreference.values
        .where((item) => item.name == value)
        .firstOrNull;
  }

  Future<void> _writeOrDelete(String key, String? value) async {
    if (value == null) {
      await SecureStorage.delete(key);
    } else {
      await SecureStorage.write(key, value);
    }
  }
}
