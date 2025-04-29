// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_staking_pool_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UiStakingPoolInfo _$UiStakingPoolInfoFromJson(Map<String, dynamic> json) =>
    UiStakingPoolInfo(
      totalAmountMxc: json['totalAmountMxc'] as String,
      rewardBalanceMxc: json['rewardBalanceMxc'] as String,
      lastDepositRewardTime:
          DateTime.parse(json['lastDepositRewardTime'] as String),
      rewardBeginEpoch: json['rewardBeginEpoch'] as String,
      currentEpoch: json['currentEpoch'] as String,
    );

Map<String, dynamic> _$UiStakingPoolInfoToJson(UiStakingPoolInfo instance) =>
    <String, dynamic>{
      'totalAmountMxc': instance.totalAmountMxc,
      'rewardBalanceMxc': instance.rewardBalanceMxc,
      'lastDepositRewardTime': instance.lastDepositRewardTime.toIso8601String(),
      'rewardBeginEpoch': instance.rewardBeginEpoch,
      'currentEpoch': instance.currentEpoch,
    };
