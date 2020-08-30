typedef FoldAggregator<V, R> = R Function(Iterable<V>);
typedef KeyedAggregator<K, V, R> = R Function(Iterable<V>, K);
typedef KeyAccessor<K, V> = K Function(V);

class GroupedIterable<K, V> extends Iterable<MapEntry<K, Iterable<V>>> {
  Map<K, Iterable<V>> data;

  GroupedIterable() : data = {};
  GroupedIterable.from(this.data);

  @override
  Iterator<MapEntry<K, Iterable<V>>> get iterator => data.entries.iterator;

  Iterable<MapEntry<K, R>> aggregate<R>(FoldAggregator<V, R> aggregator) =>
      map((entry) => MapEntry(entry.key, aggregator(entry.value)));
  Iterable<MapEntry<K, R>> aggregateWithKey<R>(KeyedAggregator<K, V, R> aggregator) =>
      map((entry) => MapEntry(entry.key, aggregator(entry.value, entry.key)));
}

class FoldAggregators {
  static FoldAggregator<V, V> min<V extends Comparable>() =>
      (values) => values.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
  static FoldAggregator<V, V> median<V extends Comparable>() => (values) {
        final list = values.toList(growable: false)..sort();
        return list[list.length ~/ 2];
      };
  static FoldAggregator<V, V> max<V extends Comparable>() =>
      (values) => values.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  static FoldAggregator<num, num> sum() => (values) => values.reduce((value, element) => value + element);
  static FoldAggregator<num, num> mean() => (values) => sum()(values) / values.length;
}

extension GroupByIterable<V> on Iterable<V> {
  GroupedIterable<K, V> groupBy<K>(KeyAccessor<K, V> key) {
    final result = <K, List<V>>{};
    forEach((element) => result.putIfAbsent(key(element), () => []).add(element));
    return GroupedIterable.from(result);
  }
}
