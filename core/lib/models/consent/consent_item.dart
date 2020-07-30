import 'package:json_annotation/json_annotation.dart';

part 'consent_item.g.dart';

@JsonSerializable()
class ConsentItem {
  String id;
  String title;
  String description;
  String iconName;

  ConsentItem();

  factory ConsentItem.fromJson(Map<String, dynamic> json) => _$ConsentItemFromJson(json);
  Map<String, dynamic> toJson() => _$ConsentItemToJson(this);

  @override
  String toString() => toJson().toString();
}
