import 'package:json_annotation/json_annotation.dart';

part 'data_reference.g.dart';

@JsonSerializable()
class DataReference<T> {
  String task;
  String property;

  DataReference();

  factory DataReference.fromJson(Map<String, dynamic> json) => _$DataReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$DataReferenceToJson(this);

  @override
  String toString() => toJson().toString();
}
