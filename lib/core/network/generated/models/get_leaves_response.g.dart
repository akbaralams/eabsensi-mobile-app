// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_leaves_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetLeavesResponse _$GetLeavesResponseFromJson(Map<String, dynamic> json) =>
    GetLeavesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Leave.fromJson(e as Map<String, dynamic>))
          .toList(),
      types: (json['types'] as List<dynamic>)
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetLeavesResponseToJson(GetLeavesResponse instance) =>
    <String, dynamic>{'data': instance.data, 'types': instance.types};
