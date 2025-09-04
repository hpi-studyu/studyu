import 'package:json_annotation/json_annotation.dart';

part 'fitbit_auth_credentials.g.dart';

@JsonSerializable()
class FitbitAuthCredentials {
  String clientId;
  String clientSecret;

  FitbitAuthCredentials({required this.clientId, required this.clientSecret});

  FitbitAuthCredentials copyWith({String? clientId, String? clientSecret}) {
    return FitbitAuthCredentials(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }

  factory FitbitAuthCredentials.fromJson(Map<String, dynamic> json) =>
      _$FitbitAuthCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$FitbitAuthCredentialsToJson(this);

  @override
  String toString() => toJson().toString();
}
