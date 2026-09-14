import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DateTimePreferences extends ChangeNotifier {
  static const _dateFormatKeyPrefix = 'date_format_';
  static const _timeFormatKeyPrefix = 'time_format_';

  DateFormatPreference? _dateFormat;
  TimeFormatPreference? _timeFormat;
  StudyUUser? _user;
  String? _userId;
  StreamSubscription<AuthState>? _authSubscription;
  int _loadGeneration = 0;

  DateTimePreferences() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) => _loadUser(authState.session?.user.id),
    );
    _loadUser(Supabase.instance.client.auth.currentUser?.id);
  }

  DateFormatPreference? get dateFormat => _dateFormat;
  TimeFormatPreference? get timeFormat => _timeFormat;

  Future<void> _loadUser(String? userId) async {
    final generation = ++_loadGeneration;
    _userId = userId;
    final localDateFormat = userId == null
        ? null
        : _parseDateFormat(
            await SecureStorage.read('$_dateFormatKeyPrefix$userId'),
          );
    final localTimeFormat = userId == null
        ? null
        : _parseTimeFormat(
            await SecureStorage.read('$_timeFormatKeyPrefix$userId'),
          );

    if (generation != _loadGeneration) return;

    if (userId == null) {
      _user = null;
      _dateFormat = localDateFormat;
      _timeFormat = localTimeFormat;
      notifyListeners();
      return;
    }

    try {
      final user = await SupabaseQuery.getById<StudyUUser>(userId);
      if (generation != _loadGeneration) return;

      _user = user;
      _dateFormat = user.preferences.dateFormat ?? localDateFormat;
      _timeFormat = user.preferences.timeFormat ?? localTimeFormat;

      final hasMigratedLocalPreferences =
          user.preferences.dateFormat == null && localDateFormat != null ||
          user.preferences.timeFormat == null && localTimeFormat != null;
      if (hasMigratedLocalPreferences) {
        user.preferences
          ..dateFormat ??= localDateFormat
          ..timeFormat ??= localTimeFormat;
        await user.save(onlyUpdate: true);
      }
    } catch (error) {
      debugPrint('Could not load date and time preferences: $error');
      _user = null;
      _dateFormat = localDateFormat;
      _timeFormat = localTimeFormat;
    }

    if (generation == _loadGeneration) notifyListeners();
  }

  Future<void> changeDateFormat(DateFormatPreference? value) async {
    _dateFormat = value;
    if (_user != null) _user!.preferences.dateFormat = value;
    await _persist(_dateFormatKeyPrefix, value?.name);
    notifyListeners();
  }

  Future<void> changeTimeFormat(TimeFormatPreference? value) async {
    _timeFormat = value;
    if (_user != null) _user!.preferences.timeFormat = value;
    await _persist(_timeFormatKeyPrefix, value?.name);
    notifyListeners();
  }

  String formatDate(BuildContext context, DateTime date) {
    return DateTimeFormat.formatDate(context, date, preference: _dateFormat);
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    return DateTimeFormat.formatTime(context, time, preference: _timeFormat);
  }

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return DateTimeFormat.formatDateTime(
      context,
      dateTime,
      datePreference: _dateFormat,
      timePreference: _timeFormat,
    );
  }

  Future<void> _persist(String keyPrefix, String? value) async {
    final userId = _user?.id ?? _userId;
    if (userId != null) {
      final key = '$keyPrefix$userId';
      if (value == null) {
        await SecureStorage.delete(key);
      } else {
        await SecureStorage.write(key, value);
      }
    }

    if (_user != null) {
      try {
        _user = await _user!.save(onlyUpdate: true);
      } catch (error) {
        debugPrint('Could not save date and time preferences: $error');
      }
    }
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
