// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);

  final String token;
  final Me user;

  Map<String, Object?> toJson() => _$LoginResponseToJson(this);
}
