// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_group_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UiGroupInfo _$UiGroupInfoFromJson(Map<String, dynamic> json) => UiGroupInfo(
      id: BigInt.parse(json['id'] as String),
      strId: json['strId'] as String,
      owner: json['owner'] as String,
      memberCount: json['memberCount'] as String,
    );

Map<String, dynamic> _$UiGroupInfoToJson(UiGroupInfo instance) =>
    <String, dynamic>{
      'id': instance.id.toString(),
      'strId': instance.strId,
      'owner': instance.owner,
      'memberCount': instance.memberCount,
    };
