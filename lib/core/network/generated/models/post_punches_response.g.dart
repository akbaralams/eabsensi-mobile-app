// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_punches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPunchesResponse _$PostPunchesResponseFromJson(Map<String, dynamic> json) =>
    PostPunchesResponse(
      data: Punch.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostPunchesResponseToJson(
  PostPunchesResponse instance,
) => <String, dynamic>{'data': instance.data};
