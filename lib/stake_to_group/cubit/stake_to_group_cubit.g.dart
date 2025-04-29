// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stake_to_group_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StakeToGroupState _$StakeToGroupStateFromJson(Map<String, dynamic> json) =>
    StakeToGroupState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      waitingMessage: json['waitingMessage'] as String,
      selectedAccount: json['selectedAccount'] as String,
      totalBalanceMxc: json['totalBalanceMxc'] as String,
      ethBalance: json['ethBalance'] as String,
      mxcBalance: json['mxcBalance'] as String,
      stakeAmount: json['stakeAmount'] as String,
      transactionInProgress: json['transactionInProgress'] as bool,
      transactionDone: json['transactionDone'] as bool,
      transactionResult: json['transactionResult'] as String,
      minDeposit: BigInt.parse(json['minDeposit'] as String),
      minDepositMxc: json['minDepositMxc'] as String,
      groupList: (json['groupList'] as List<dynamic>)
          .map((e) => UiGroupInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedGroup:
          UiGroupInfo.fromJson(json['selectedGroup'] as Map<String, dynamic>),
      inGroup: json['inGroup'] as bool,
    );

Map<String, dynamic> _$StakeToGroupStateToJson(StakeToGroupState instance) =>
    <String, dynamic>{
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'waiting': instance.waiting,
      'waitingMessage': instance.waitingMessage,
      'selectedAccount': instance.selectedAccount,
      'totalBalanceMxc': instance.totalBalanceMxc,
      'ethBalance': instance.ethBalance,
      'mxcBalance': instance.mxcBalance,
      'stakeAmount': instance.stakeAmount,
      'transactionInProgress': instance.transactionInProgress,
      'transactionDone': instance.transactionDone,
      'transactionResult': instance.transactionResult,
      'minDeposit': instance.minDeposit.toString(),
      'minDepositMxc': instance.minDepositMxc,
      'groupList': instance.groupList,
      'selectedGroup': instance.selectedGroup,
      'inGroup': instance.inGroup,
    };
