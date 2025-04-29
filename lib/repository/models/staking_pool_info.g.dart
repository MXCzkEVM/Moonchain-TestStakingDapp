// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking_pool_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StakingPoolInfo _$StakingPoolInfoFromJson(Map<String, dynamic> json) =>
    StakingPoolInfo(
      totalAmount: BigInt.parse(json['totalAmount'] as String),
      rewardBalance: BigInt.parse(json['rewardBalance'] as String),
      lastDepositRewardTime:
          DateTime.parse(json['lastDepositRewardTime'] as String),
      rewardBeginEpoch: BigInt.parse(json['rewardBeginEpoch'] as String),
      currentEpoch: BigInt.parse(json['currentEpoch'] as String),
    );

Map<String, dynamic> _$StakingPoolInfoToJson(StakingPoolInfo instance) =>
    <String, dynamic>{
      'totalAmount': instance.totalAmount.toString(),
      'rewardBalance': instance.rewardBalance.toString(),
      'lastDepositRewardTime': instance.lastDepositRewardTime.toIso8601String(),
      'rewardBeginEpoch': instance.rewardBeginEpoch.toString(),
      'currentEpoch': instance.currentEpoch.toString(),
    };
