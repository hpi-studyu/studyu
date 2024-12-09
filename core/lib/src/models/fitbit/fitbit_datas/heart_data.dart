import 'package:json_annotation/json_annotation.dart';

import 'fibit_data.dart';

part 'heart_data.g.dart';

@JsonSerializable()
class FitbitHeartData extends FitbitData<FitbitHeartData> {
  static const String dataType = 'heart';
  double value;

  FitbitHeartData(this.value, DateTime dateTime) : super(dataType, dateTime);

  factory FitbitHeartData.fromJson(Map<String, dynamic> json) =>
      _$FitbitHeartDataFromJson(json);

  Map<String, dynamic> toJson() => _$FitbitHeartDataToJson(this);
}
