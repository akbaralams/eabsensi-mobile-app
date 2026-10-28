// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Option _$OptionFromJson(Map<String, dynamic> json) => Option(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$OptionToJson(Option instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
};
