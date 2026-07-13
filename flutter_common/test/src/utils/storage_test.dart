import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

void main() {
  test('scopes storage outside the production environment', () {
    expect(storageKeyForEnvironment('user_email', '.env'), 'user_email');
    expect(
      storageKeyForEnvironment('user_email', '.env.dev'),
      '.env.dev:user_email',
    );
    expect(
      storageKeyForEnvironment('user_email', '.env.local'),
      '.env.local:user_email',
    );
  });
}
