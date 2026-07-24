import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('missing completion confirmation defaults to required', () {
    final task = NutritionTask.withId();
    final json = task.toJson()..remove('requireDailyCompletionConfirmation');

    expect(
      NutritionTask.fromJson(json).requireDailyCompletionConfirmation,
      isTrue,
    );
  });

  test('serializes an explicitly optional daily completion', () {
    final task = NutritionTask.withId()
      ..requireDailyCompletionConfirmation = false;

    final restored = NutritionTask.fromJson(task.toJson());

    expect(restored.requireDailyCompletionConfirmation, isFalse);
  });
}
