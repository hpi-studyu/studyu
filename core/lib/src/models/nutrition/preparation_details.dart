import 'package:json_annotation/json_annotation.dart';

part 'preparation_details.g.dart';

@JsonSerializable()
class PreparationDetails {
  double rawWeight;
  double cookedWeight;
  double yieldFactor;
  String preparationMethod;
  Map<String, double> retentionFactors;

  PreparationDetails({
    required this.rawWeight,
    required this.cookedWeight,
    required this.yieldFactor,
    required this.preparationMethod,
    required this.retentionFactors,
  });

  factory PreparationDetails.fromJson(Map<String, dynamic> json) =>
      _$PreparationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PreparationDetailsToJson(this);

  @override
  String toString() => toJson().toString();
}
