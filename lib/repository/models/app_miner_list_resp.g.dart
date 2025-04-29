// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_miner_list_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppMinerListItem _$AppMinerListItemFromJson(Map<String, dynamic> json) =>
    AppMinerListItem(
      instanceId: (json['instanceId'] as num).toInt(),
      lastPing: json['lastPing'] as String,
      online: (json['online'] as num).toDouble(),
    );

Map<String, dynamic> _$AppMinerListItemToJson(AppMinerListItem instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'lastPing': instance.lastPing,
      'online': instance.online,
    };

AppMinerListResult _$AppMinerListResultFromJson(Map<String, dynamic> json) =>
    AppMinerListResult(
      count: (json['count'] as num).toInt(),
      minerList: (json['minerList'] as List<dynamic>)
          .map((e) => AppMinerListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppMinerListResultToJson(AppMinerListResult instance) =>
    <String, dynamic>{
      'count': instance.count,
      'minerList': instance.minerList,
    };

AppMinerListResp _$AppMinerListRespFromJson(Map<String, dynamic> json) =>
    AppMinerListResp(
      ret: (json['ret'] as num).toInt(),
      message: json['message'] as String,
      result:
          AppMinerListResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppMinerListRespToJson(AppMinerListResp instance) =>
    <String, dynamic>{
      'ret': instance.ret,
      'message': instance.message,
      'result': instance.result,
    };
