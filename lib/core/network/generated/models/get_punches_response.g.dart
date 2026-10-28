// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_punches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPunchesResponse _$GetPunchesResponseFromJson(Map<String, dynamic> json) =>
    GetPunchesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Punch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetPunchesResponseToJson(GetPunchesResponse instance) =>
    <String, dynamic>{'data': instance.data};
