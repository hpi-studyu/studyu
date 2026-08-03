import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/fitbit_handler.dart';

void main() {
  group('FitbitHandler', () {
    test('discards legacy credentials when authenticated user is present', () {
      expect(
        FitbitHandler.shouldDiscardLegacyCredentialsForAuthenticatedUser(
          'user-1',
        ),
        isTrue,
      );
    });

    test(
      'keeps legacy credentials available before authentication is restored',
      () {
        expect(
          FitbitHandler.shouldDiscardLegacyCredentialsForAuthenticatedUser(
            null,
          ),
          isFalse,
        );
      },
    );
  });
}
