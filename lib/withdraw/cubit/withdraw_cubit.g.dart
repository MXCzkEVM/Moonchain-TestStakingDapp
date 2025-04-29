// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawState _$WithdrawStateFromJson(Map<String, dynamic> json) =>
    WithdrawState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      waitingMessage: json['waitingMessage'] as String,
      selectedAccount: json['selectedAccount'] as String,
      ethBalance: json['ethBalance'] as String,
      mxcBalance: json['mxcBalance'] as String,
      transactionInProgress: json['transactionInProgress'] as bool,
      transactionDone: json['transactionDone'] as bool,
      transactionResult: json['transactionResult'] as String,
      currentEpoch: json['currentEpoch'] as String,
      stakingBalances: BigInt.parse(json['stakingBalances'] as String),
      stakingBalancesMxc: json['stakingBalancesMxc'] as String,
      withdrawalRequestEpoch:
          BigInt.parse(json['withdrawalRequestEpoch'] as String),
      strWithdrawalRequestEpoch: json['strWithdrawalRequestEpoch'] as String,
      withDrawLockEpoch: BigInt.parse(json['withDrawLockEpoch'] as String),
      isLocked: json['isLocked'] as bool,
      grossReward: BigInt.parse(json['grossReward'] as String),
      grossRewardMxc: json['grossRewardMxc'] as String,
    );

Map<String, dynamic> _$WithdrawStateToJson(WithdrawState instance) =>
    <String, dynamic>{
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'waiting': instance.waiting,
      'waitingMessage': instance.waitingMessage,
      'selectedAccount': instance.selectedAccount,
      'ethBalance': instance.ethBalance,
      'mxcBalance': instance.mxcBalance,
      'transactionInProgress': instance.transactionInProgress,
      'transactionDone': instance.transactionDone,
      'transactionResult': instance.transactionResult,
      'currentEpoch': instance.currentEpoch,
      'stakingBalances': instance.stakingBalances.toString(),
      'stakingBalancesMxc': instance.stakingBalancesMxc,
      'withdrawalRequestEpoch': instance.withdrawalRequestEpoch.toString(),
      'strWithdrawalRequestEpoch': instance.strWithdrawalRequestEpoch,
      'withDrawLockEpoch': instance.withDrawLockEpoch.toString(),
      'isLocked': instance.isLocked,
      'grossReward': instance.grossReward.toString(),
      'grossRewardMxc': instance.grossRewardMxc,
    };
