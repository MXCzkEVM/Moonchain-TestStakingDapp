// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_miner_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UiMinerInfo _$UiMinerInfoFromJson(Map<String, dynamic> json) => UiMinerInfo(
      instanceId: json['instanceId'] as String,
      lastPing: json['lastPing'] as String,
      online: json['online'] as String,
    );

Map<String, dynamic> _$UiMinerInfoToJson(UiMinerInfo instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'lastPing': instance.lastPing,
      'online': instance.online,
    };
