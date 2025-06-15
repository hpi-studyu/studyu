import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'body_part.g.dart';

@JsonSerializable()
class BodyPart {
  final String id;

  final String name;

  final BodyPain pain;

  final List<BodyPart> children;

  const BodyPart({
    required this.id,
    required this.name,
    this.pain = const BodyPain(),
    this.children = const [],
  });

  BodyPart copyWith({
    String? id,
    String? name,
    BodyPain? pain,
    List<BodyPart>? children,
  }) {
    return BodyPart(
      id: id ?? this.id,
      name: name ?? this.name,
      pain: pain ?? this.pain,
      children: children ?? this.children,
    );
  }

  factory BodyPart.fromJson(Map<String, dynamic> json) =>
      _$BodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPartToJson(this);
}
