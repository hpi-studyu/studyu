import 'package:json_annotation/json_annotation.dart';

part 'fitbit_credentials.g.dart';

@JsonSerializable()
class FitbitCredentials {
  String clientId;
  String clientSecret;

  FitbitCredentials({
    required this.clientId,
    required this.clientSecret,
  });

  FitbitCredentials copyWith({
    String? clientId,
    String? clientSecret,
  }) {
    return FitbitCredentials(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }

  factory FitbitCredentials.fromJson(Map<String, dynamic> json) =>
      _$FitbitCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$FitbitCredentialsToJson(this);

  @override
  String toString() => toJson().toString();
}
