import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_sleep_data.g.dart';

@JsonSerializable()
class FitbitSleepData extends FitbitData {
  static const String dataType = 'steps';
  DateTime dateOfSleep;
  String level;

  FitbitSleepData(
    this.dateOfSleep,
    this.level,
    DateTime dateTime,
  ) : super(dataType, dateTime);

  factory FitbitSleepData.fromJson(Map<String, dynamic> json) =>
      _$FitbitSleepDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitSleepDataToJson(this);
}
