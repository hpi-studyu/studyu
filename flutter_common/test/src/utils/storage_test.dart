import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

void main() {
  test('Supabase session storage is isolated by debug environment', () {
    final developmentKey = supabaseSessionStorageKey('.env.dev');
    final productionKey = supabaseSessionStorageKey('.env');

    expect(developmentKey, isNot(productionKey));
    expect(supabaseSessionStorageKey(null), 'SUPABASE_PERSIST_SESSION_KEY');
  });
}
