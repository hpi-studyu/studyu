import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('server System selection ignores a non-dirty cached preference', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: null,
        localValue: DateFormatPreference.german,
        localValueIsDirty: false,
      ),
      isNull,
    );
  });

  test('a dirty offline preference wins during synchronization', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: DateFormatPreference.us,
        localValue: DateFormatPreference.german,
        localValueIsDirty: true,
      ),
      DateFormatPreference.german,
    );
  });

  test('a dirty offline System selection remains System', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: DateFormatPreference.us,
        localValue: null,
        localValueIsDirty: true,
      ),
      isNull,
    );
  });
}
