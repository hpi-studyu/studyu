import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  String organization;
  String researchers;
  String email;
  String website;
  String phone;

  Contact();

  Contact.designerDefault()
      : organization = '',
        researchers = '',
        email = '',
        website = '',
        phone = '';

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  String toString() => toJson().toString();
}
