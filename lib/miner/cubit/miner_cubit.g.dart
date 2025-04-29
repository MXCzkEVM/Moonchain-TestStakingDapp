// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miner_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinerState _$MinerStateFromJson(Map<String, dynamic> json) => MinerState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      waitingMessage: json['waitingMessage'] as String,
      selectedAccount: json['selectedAccount'] as String,
      appToken: json['appToken'] as String,
      minerCount: (json['minerCount'] as num).toInt(),
      minerList: (json['minerList'] as List<dynamic>)
          .map((e) => UiMinerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MinerStateToJson(MinerState instance) =>
    <String, dynamic>{
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'waiting': instance.waiting,
      'waitingMessage': instance.waitingMessage,
      'selectedAccount': instance.selectedAccount,
      'appToken': instance.appToken,
      'minerCount': instance.minerCount,
      'minerList': instance.minerList,
    };
