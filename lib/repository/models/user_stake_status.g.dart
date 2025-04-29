// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stake_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStakeStatus _$UserStakeStatusFromJson(Map<String, dynamic> json) =>
    UserStakeStatus(
      stakingGroup: BigInt.parse(json['stakingGroup'] as String),
      stakedAmount: BigInt.parse(json['stakedAmount'] as String),
      lastClaimedEpoch: BigInt.parse(json['lastClaimedEpoch'] as String),
      withdrawalRequestEpoch:
          BigInt.parse(json['withdrawalRequestEpoch'] as String),
    );

Map<String, dynamic> _$UserStakeStatusToJson(UserStakeStatus instance) =>
    <String, dynamic>{
      'stakingGroup': instance.stakingGroup.toString(),
      'stakedAmount': instance.stakedAmount.toString(),
      'lastClaimedEpoch': instance.lastClaimedEpoch.toString(),
      'withdrawalRequestEpoch': instance.withdrawalRequestEpoch.toString(),
    };
