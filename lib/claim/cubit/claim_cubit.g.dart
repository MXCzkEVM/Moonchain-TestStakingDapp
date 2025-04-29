// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimState _$ClaimStateFromJson(Map<String, dynamic> json) => ClaimState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      waitingMessage: json['waitingMessage'] as String,
      selectedAccount: json['selectedAccount'] as String,
      totalBalanceMxc: json['totalBalanceMxc'] as String,
      ethBalance: json['ethBalance'] as String,
      mxcBalance: json['mxcBalance'] as String,
      transactionInProgress: json['transactionInProgress'] as bool,
      transactionDone: json['transactionDone'] as bool,
      transactionResult: json['transactionResult'] as String,
      currentEpoch: json['currentEpoch'] as String,
      rewardBeginEpoch: json['rewardBeginEpoch'] as String,
      lastClaimedEpoch: json['lastClaimedEpoch'] as String,
      stakingBalancesMxc: json['stakingBalancesMxc'] as String,
      stakingBalances: BigInt.parse(json['stakingBalances'] as String),
      grossReward: BigInt.parse(json['grossReward'] as String),
      grossRewardMxc: json['grossRewardMxc'] as String,
      netRewardMxc: json['netRewardMxc'] as String,
    );

Map<String, dynamic> _$ClaimStateToJson(ClaimState instance) =>
    <String, dynamic>{
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'waiting': instance.waiting,
      'waitingMessage': instance.waitingMessage,
      'selectedAccount': instance.selectedAccount,
      'totalBalanceMxc': instance.totalBalanceMxc,
      'ethBalance': instance.ethBalance,
      'mxcBalance': instance.mxcBalance,
      'transactionInProgress': instance.transactionInProgress,
      'transactionDone': instance.transactionDone,
      'transactionResult': instance.transactionResult,
      'currentEpoch': instance.currentEpoch,
      'rewardBeginEpoch': instance.rewardBeginEpoch,
      'lastClaimedEpoch': instance.lastClaimedEpoch,
      'stakingBalancesMxc': instance.stakingBalancesMxc,
      'stakingBalances': instance.stakingBalances.toString(),
      'grossReward': instance.grossReward.toString(),
      'grossRewardMxc': instance.grossRewardMxc,
      'netRewardMxc': instance.netRewardMxc,
    };
