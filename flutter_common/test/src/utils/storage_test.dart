import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

void main() {
  test('Supabase session storage is isolated by backend origin', () {
    final developmentKey = supabaseSessionStorageKey(
      'https://development.supabase.co',
    );
    final productionKey = supabaseSessionStorageKey(
      'https://production.supabase.co',
    );
    final localKey = supabaseSessionStorageKey('http://localhost:54321');

    expect(developmentKey, isNot(productionKey));
    expect(localKey, contains('localhost%3A54321'));
    expect(supabaseSessionStorageKey(null), 'SUPABASE_PERSIST_SESSION_KEY');
  });
}
