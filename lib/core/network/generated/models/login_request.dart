// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  const LoginRequest({
    required this.login,
    required this.password,
    required this.deviceName,
  });

  factory LoginRequest.fromJson(Map<String, Object?> json) =>
      _$LoginRequestFromJson(json);

  /// Username atau email
  final String login;
  final String password;

  /// Nama perangkat; satu token per nama
  @JsonKey(name: 'device_name')
  final String deviceName;

  Map<String, Object?> toJson() => _$LoginRequestToJson(this);
}
