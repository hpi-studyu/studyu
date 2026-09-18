import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@visibleForTesting
T? synchronizedPreference<T>({
  required T? serverValue,
  required T? localValue,
  required bool localValueIsDirty,
}) => localValueIsDirty ? localValue : serverValue;

class DateTimePreferences() extends ChangeNotifier {
  static const _dateFormatKeyPrefix = 'date_format_';
  static const _timeFormatKeyPrefix = 'time_format_';
  static const _dateFormatDirtyKeyPrefix = 'date_format_dirty_';
  static const _timeFormatDirtyKeyPrefix = 'time_format_dirty_';

  DateFormatPreference? _dateFormat;
  TimeFormatPreference? _timeFormat;
  StudyUUser? _user;
  String? _userId;
  StreamSubscription<AuthState>? _authSubscription;
  int _loadGeneration = 0;

  this {
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
    _user = null;
    _dateFormat = null;
    _timeFormat = null;
    notifyListeners();

    DateFormatPreference? localDateFormat;
    TimeFormatPreference? localTimeFormat;
    var localDateFormatIsDirty = false;
    var localTimeFormatIsDirty = false;
    if (userId != null) {
      try {
        localDateFormat = _parseDateFormat(
          await SecureStorage.read('$_dateFormatKeyPrefix$userId'),
        );
        localTimeFormat = _parseTimeFormat(
          await SecureStorage.read('$_timeFormatKeyPrefix$userId'),
        );
        localDateFormatIsDirty =
            await SecureStorage.readBool('$_dateFormatDirtyKeyPrefix$userId') ??
            false;
        localTimeFormatIsDirty =
            await SecureStorage.readBool('$_timeFormatDirtyKeyPrefix$userId') ??
            false;
      } catch (error) {
        debugPrint('Could not read local date and time preferences: $error');
      }
    }

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
      final dateFormat = synchronizedPreference(
        serverValue: user.preferences.dateFormat,
        localValue: localDateFormat,
        localValueIsDirty: localDateFormatIsDirty,
      );
      final timeFormat = synchronizedPreference(
        serverValue: user.preferences.timeFormat,
        localValue: localTimeFormat,
        localValueIsDirty: localTimeFormatIsDirty,
      );
      _dateFormat = dateFormat;
      _timeFormat = timeFormat;

      if (localDateFormatIsDirty) user.preferences.dateFormat = dateFormat;
      if (localTimeFormatIsDirty) user.preferences.timeFormat = timeFormat;

      final hasUnsynchronizedLocalPreferences =
          localDateFormatIsDirty || localTimeFormatIsDirty;
      if (hasUnsynchronizedLocalPreferences) {
        try {
          final synchronizedUser = await user.save(onlyUpdate: true);
          if (generation != _loadGeneration) return;
          _user = synchronizedUser;
          if (localDateFormatIsDirty &&
              await _cachePreference(
                _dateFormatKeyPrefix,
                userId,
                dateFormat,
              )) {
            await _clearDirtyPreference(_dateFormatDirtyKeyPrefix, userId);
          }
          if (localTimeFormatIsDirty &&
              await _cachePreference(
                _timeFormatKeyPrefix,
                userId,
                timeFormat,
              )) {
            await _clearDirtyPreference(_timeFormatDirtyKeyPrefix, userId);
          }
        } catch (error) {
          debugPrint(
            'Could not synchronize local date and time preferences: $error',
          );
        }
      } else {
        await _cachePreference(_dateFormatKeyPrefix, userId, dateFormat);
        await _cachePreference(_timeFormatKeyPrefix, userId, timeFormat);
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
    final generation = _loadGeneration;
    final userId = _userId;
    final user = _user;
    final previousValue = _dateFormat;
    final previousUserValue = user?.preferences.dateFormat;
    _dateFormat = value;
    if (user != null) user.preferences.dateFormat = value;
    try {
      await _persist(
        _dateFormatKeyPrefix,
        value?.name,
        generation: generation,
        userId: userId,
        user: user,
      );
    } catch (error) {
      if (_isCurrent(generation, userId)) {
        _dateFormat = previousValue;
        if (user != null && _user == user) {
          _user!.preferences.dateFormat = previousUserValue;
        }
        notifyListeners();
      }
      rethrow;
    }
    if (_isCurrent(generation, userId)) notifyListeners();
  }

  Future<void> changeTimeFormat(TimeFormatPreference? value) async {
    final generation = _loadGeneration;
    final userId = _userId;
    final user = _user;
    final previousValue = _timeFormat;
    final previousUserValue = user?.preferences.timeFormat;
    _timeFormat = value;
    if (user != null) user.preferences.timeFormat = value;
    try {
      await _persist(
        _timeFormatKeyPrefix,
        value?.name,
        generation: generation,
        userId: userId,
        user: user,
      );
    } catch (error) {
      if (_isCurrent(generation, userId)) {
        _timeFormat = previousValue;
        if (user != null && _user == user) {
          _user!.preferences.timeFormat = previousUserValue;
        }
        notifyListeners();
      }
      rethrow;
    }
    if (_isCurrent(generation, userId)) notifyListeners();
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

  Future<void> _persist(
    String keyPrefix,
    String? value, {
    required int generation,
    required String? userId,
    required StudyUUser? user,
  }) async {
    final dirtyKeyPrefix = keyPrefix == _dateFormatKeyPrefix
        ? _dateFormatDirtyKeyPrefix
        : _timeFormatDirtyKeyPrefix;
    if (userId == null) return;

    final cacheKey = '$keyPrefix$userId';
    final dirtyKey = '$dirtyKeyPrefix$userId';
    final previousCachedValue = await SecureStorage.read(cacheKey);
    final previousDirtyValue = await SecureStorage.readBool(dirtyKey);

    if (user == null) {
      try {
        await _writeCachedPreference(cacheKey, value);
        await SecureStorage.write(dirtyKey, 'true');
      } catch (error) {
        await _restorePreference(
          cacheKey,
          dirtyKey,
          previousCachedValue,
          previousDirtyValue,
        );
        rethrow;
      }
      return;
    }

    final savedUser = await user.save(onlyUpdate: true);
    await _cachePreference(keyPrefix, userId, value);
    await _clearDirtyPreference(dirtyKeyPrefix, userId);
    if (_isCurrent(generation, userId)) _user = savedUser;
  }

  bool _isCurrent(int generation, String? userId) {
    return generation == _loadGeneration && userId == _userId;
  }

  Future<void> _writeCachedPreference(String key, Object? value) async {
    if (value == null) {
      await SecureStorage.delete(key);
    } else {
      await SecureStorage.write(key, value.toString());
    }
  }

  Future<void> _restorePreference(
    String cacheKey,
    String dirtyKey,
    String? cachedValue,
    bool? dirtyValue,
  ) async {
    try {
      await _writeCachedPreference(cacheKey, cachedValue);
      if (dirtyValue == null) {
        await SecureStorage.delete(dirtyKey);
      } else {
        await SecureStorage.write(dirtyKey, dirtyValue.toString());
      }
    } catch (restoreError) {
      debugPrint('Could not restore date and time preferences: $restoreError');
    }
  }

  Future<bool> _cachePreference(
    String keyPrefix,
    String userId,
    Object? value,
  ) async {
    try {
      final key = '$keyPrefix$userId';
      if (value == null) {
        await SecureStorage.delete(key);
      } else {
        await SecureStorage.write(key, value.toString());
      }
      return true;
    } catch (error) {
      debugPrint('Could not cache date and time preference: $error');
      return false;
    }
  }

  Future<void> _clearDirtyPreference(String keyPrefix, String userId) async {
    try {
      await SecureStorage.delete('$keyPrefix$userId');
    } catch (error) {
      debugPrint(
        'Could not clear synchronized date and time preference: $error',
      );
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
