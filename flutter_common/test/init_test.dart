import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      DateTimeFormat.defaultDateFormat(const Locale('fr', 'FR')),
      DateFormatPreference.iso,
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
