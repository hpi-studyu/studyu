import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_heart_data.g.dart';

@JsonSerializable()
class FitbitHeartData extends FitbitData {
  static const String dataType = 'heart';
  double value;

  FitbitHeartData(this.value, DateTime dateTime) : super(dataType, dateTime);

  factory FitbitHeartData.fromJson(Map<String, dynamic> json) =>
      _$FitbitHeartDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitHeartDataToJson(this);
}
