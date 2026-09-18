import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/date_time_format.dart';
import 'package:studyu_flutter_common/src/utils/user.dart';

void main() {
  test('infers date format from locale', () {
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('de', 'DE')),
      DateFormatPreference.german,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'US')),
      DateFormatPreference.us,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'GB')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'AU')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'IE')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('fr', 'FR')),
      DateFormatPreference.iso,
    );
  });

  test('infers time format from locale', () {
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('en', 'US')),
      TimeFormatPreference.h12,
    );
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('en', 'GB')),
      TimeFormatPreference.h24,
    );
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('de', 'DE')),
      TimeFormatPreference.h24,
    );
  });

  test('uses the supplied locale for default formatting', () async {
    await initializeDateFormatting('de_DE');
    expect(
      DateTimeFormat.formatDateForLocale(
        const Locale('de', 'DE'),
        DateTime(2024, 12, 31),
      ),
      '31.12.2024',
    );
    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        const TimeOfDay(hour: 14, minute: 30),
      ),
      '2:30 PM',
    );
  });

  test('formats time with the selected preference', () {
    const time = TimeOfDay(hour: 14, minute: 30);

    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        time,
        preference: TimeFormatPreference.h12,
      ),
      '2:30 PM',
    );
    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        time,
        preference: TimeFormatPreference.h24,
      ),
      '14:30',
    );
  });

  test('ensureParticipantSignedIn returns true for existing session', () async {
    var signInCalls = 0;
    var signUpCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
      signIn: () async {
        signInCalls++;
        return false;
      },
      signUp: () async {
        signUpCalls++;
        return false;
      },
    );

    expect(success, isTrue);
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

  test(
    'ensureParticipantSignedIn reuses stored participant credentials',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => true,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 0);
    },
  );

  test(
    'ensureParticipantSignedIn signs up when no session can be restored',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => false,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 1);
    },
  );
}
