// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGroupState _$CreateGroupStateFromJson(Map<String, dynamic> json) =>
    CreateGroupState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      waitingMessage: json['waitingMessage'] as String,
      selectedAccount: json['selectedAccount'] as String,
      ethBalance: json['ethBalance'] as String,
      mxcBalance: json['mxcBalance'] as String,
      transactionInProgress: json['transactionInProgress'] as bool,
      transactionDone: json['transactionDone'] as bool,
      transactionResult: json['transactionResult'] as String,
      minDeposit: BigInt.parse(json['minDeposit'] as String),
      minDepositMxc: json['minDepositMxc'] as String,
    );

Map<String, dynamic> _$CreateGroupStateToJson(CreateGroupState instance) =>
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
      'minDeposit': instance.minDeposit.toString(),
      'minDepositMxc': instance.minDepositMxc,
    };
