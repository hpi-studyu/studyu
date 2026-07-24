import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

const _historySectionLimit = 5;

final class FoodSearchHistory {
  final List<FoodSearchHistoryItem> recent;
  final List<FoodSearchHistoryItem> frequentlyUsed;

  const FoodSearchHistory({required this.recent, required this.frequentlyUsed});

  static const empty = FoodSearchHistory(recent: [], frequentlyUsed: []);
}

final class FoodSearchHistoryItem {
  final String identity;
  final FoodEntry food;
  final int useCount;
  final DateTime lastUsedAt;

  const FoodSearchHistoryItem({
    required this.identity,
    required this.food,
    required this.useCount,
    required this.lastUsedAt,
  });

  FoodEntry createSelection() => duplicateFoodEntry(food);
}

FoodSearchHistory buildFoodSearchHistory(
  Iterable<SubjectProgress> progress, {
  required String subjectId,
}) {
  final entries = <String, _HistoryAccumulator>{};

  for (final item in progress) {
    if (item.subjectId != subjectId || item.resultType != 'DailyRecall') {
      continue;
    }
    final result = item.result.result;
    if (result is! DailyRecall) continue;

    for (final meal in result.meals) {
      final occurrenceTimestamp =
          meal.timePrecision == MealOccurrenceTimePrecision.unknown
          ? null
          : meal.timestamp;
      final historyDate = occurrenceTimestamp ?? result.date;
      for (final food in meal.foods) {
        final identity = foodHistoryIdentity(food);
        final existing = entries[identity];
        if (existing == null) {
          entries[identity] = _HistoryAccumulator(
            food: cloneFoodEntry(food),
            useCount: 1,
            lastUsedAt: historyDate,
          );
          continue;
        }

        existing.useCount++;
        if (historyDate.isAfter(existing.lastUsedAt) ||
            (historyDate == existing.lastUsedAt &&
                food.id.compareTo(existing.food.id) < 0)) {
          existing
            ..food = cloneFoodEntry(food)
            ..lastUsedAt = historyDate;
        }
      }
    }
  }

  final all = entries.entries
      .map(
        (entry) => FoodSearchHistoryItem(
          identity: entry.key,
          food: entry.value.food,
          useCount: entry.value.useCount,
          lastUsedAt: entry.value.lastUsedAt,
        ),
      )
      .toList();

  final frequentlyUsed = all.where((item) => item.useCount > 1).toList()
    ..sort(_compareFrequentlyUsed);
  final visibleFrequentlyUsed = frequentlyUsed
      .take(_historySectionLimit)
      .toList(growable: false);
  final frequentIdentities = visibleFrequentlyUsed
      .map((item) => item.identity)
      .toSet();

  final recent =
      all.where((item) => !frequentIdentities.contains(item.identity)).toList()
        ..sort(_compareRecent);

  return FoodSearchHistory(
    recent: recent.take(_historySectionLimit).toList(growable: false),
    frequentlyUsed: visibleFrequentlyUsed,
  );
}

String foodHistoryIdentity(FoodEntry food) {
  final externalId = food.externalId?.trim();
  if (externalId != null && externalId.isNotEmpty) {
    return '${food.source.name}|external|${_normalize(externalId)}';
  }
  return '${_normalize(food.name)}|${_normalize(food.brandName ?? '')}|${_normalize(food.unit)}';
}

int _compareFrequentlyUsed(
  FoodSearchHistoryItem left,
  FoodSearchHistoryItem right,
) {
  final countComparison = right.useCount.compareTo(left.useCount);
  if (countComparison != 0) return countComparison;
  return _compareRecent(left, right);
}

int _compareRecent(FoodSearchHistoryItem left, FoodSearchHistoryItem right) {
  final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
  if (dateComparison != 0) return dateComparison;
  return left.identity.compareTo(right.identity);
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

final class _HistoryAccumulator {
  FoodEntry food;
  int useCount;
  DateTime lastUsedAt;

  _HistoryAccumulator({
    required this.food,
    required this.useCount,
    required this.lastUsedAt,
  });
}
