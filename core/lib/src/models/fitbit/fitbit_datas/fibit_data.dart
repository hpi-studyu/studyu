abstract class FitbitData<V> {
  String type;
  DateTime dateTime;

  FitbitData(this.type, this.dateTime);

  Type getDataType() => V;

  @override
  String toString() {
    return 'FitbitData(dateTime: $dateTime)';
  }
}
