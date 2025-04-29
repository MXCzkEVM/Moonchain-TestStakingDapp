// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_user_stake_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UiUserStakeStatus _$UiUserStakeStatusFromJson(Map<String, dynamic> json) =>
    UiUserStakeStatus(
      stakingBalancesMxc: json['stakingBalancesMxc'] as String,
      lastClaimedEpoch: BigInt.parse(json['lastClaimedEpoch'] as String),
      strLastClaimedEpoch: json['strLastClaimedEpoch'] as String,
      withdrawalRequestEpoch: json['withdrawalRequestEpoch'] as String,
      stakingGroupId: BigInt.parse(json['stakingGroupId'] as String),
      isGroupLeader: json['isGroupLeader'] as bool,
    );

Map<String, dynamic> _$UiUserStakeStatusToJson(UiUserStakeStatus instance) =>
    <String, dynamic>{
      'stakingBalancesMxc': instance.stakingBalancesMxc,
      'lastClaimedEpoch': instance.lastClaimedEpoch.toString(),
      'strLastClaimedEpoch': instance.strLastClaimedEpoch,
      'withdrawalRequestEpoch': instance.withdrawalRequestEpoch,
      'stakingGroupId': instance.stakingGroupId.toString(),
      'isGroupLeader': instance.isGroupLeader,
    };
