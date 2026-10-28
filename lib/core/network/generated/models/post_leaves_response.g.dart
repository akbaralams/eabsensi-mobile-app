// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_leaves_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLeavesResponse _$PostLeavesResponseFromJson(Map<String, dynamic> json) =>
    PostLeavesResponse(
      data: Leave.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostLeavesResponseToJson(PostLeavesResponse instance) =>
    <String, dynamic>{'data': instance.data};
