import 'package:studyu_core/core.dart';

abstract class FitbitData {
  String type;
  DateTime dateTime;

  FitbitData(this.type, this.dateTime);

  @override
  String toString() {
    return 'FitbitData(type: $type, dateTime: $dateTime)';
  }

  Map<String, dynamic> toJson();

  factory FitbitData.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case FitbitHeartData.dataType:
        return FitbitHeartData.fromJson(json) as FitbitData;
      case FitbitSleepData.dataType:
        return FitbitSleepData.fromJson(json) as FitbitData;
      case FitbitStepData.dataType:
        return FitbitStepData.fromJson(json) as FitbitData;
      default:
        throw Exception('Unknown FitbitData type: ${json['type']}');
    }
  }
}
