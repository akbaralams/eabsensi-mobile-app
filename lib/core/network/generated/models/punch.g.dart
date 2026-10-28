// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Punch _$PunchFromJson(Map<String, dynamic> json) => Punch(
  id: (json['id'] as num).toInt(),
  punchedAt: json['punched_at'] as String,
  source: PunchSource.fromJson(json['source'] as String),
  status: PunchStatus.fromJson(json['status'] as String),
  statusLabel: json['status_label'] as String,
  hasPhoto: json['has_photo'] as bool,
);

Map<String, dynamic> _$PunchToJson(Punch instance) => <String, dynamic>{
  'id': instance.id,
  'punched_at': instance.punchedAt,
  'source': instance.source,
  'status': instance.status,
  'status_label': instance.statusLabel,
  'has_photo': instance.hasPhoto,
};
