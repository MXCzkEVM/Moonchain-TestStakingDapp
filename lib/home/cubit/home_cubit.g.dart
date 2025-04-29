// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeState _$HomeStateFromJson(Map<String, dynamic> json) => HomeState(
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      waiting: json['waiting'] as bool,
      isNetworkConnected: json['isNetworkConnected'] as bool,
      chainId: (json['chainId'] as num).toInt(),
      chainName: json['chainName'] as String,
      isTestnet: json['isTestnet'] as bool,
      isTargetChain: json['isTargetChain'] as bool,
      blockNumber: BigInt.parse(json['blockNumber'] as String),
      gasPrice: BigInt.parse(json['gasPrice'] as String),
      accountList: (json['accountList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selectedAccount: json['selectedAccount'] as String,
      ethersVersion: json['ethersVersion'] as String,
      taikoL1Address: json['taikoL1Address'] as String,
      l1StakingAddress: json['l1StakingAddress'] as String,
      mxcTokenAddress: json['mxcTokenAddress'] as String,
      zkCenterAddress: json['zkCenterAddress'] as String,
      zkCenterName2: json['zkCenterName2'] as String,
      stakingPoolInfo: UiStakingPoolInfo.fromJson(
          json['stakingPoolInfo'] as Map<String, dynamic>),
      userStakeStatus: UiUserStakeStatus.fromJson(
          json['userStakeStatus'] as Map<String, dynamic>),
      ethBalance: json['ethBalance'] as String,
      mxcBalance: json['mxcBalance'] as String,
      grossReward: BigInt.parse(json['grossReward'] as String),
      grossRewardMxc: json['grossRewardMxc'] as String,
      minerCount: (json['minerCount'] as num).toInt(),
    );

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'waiting': instance.waiting,
      'isNetworkConnected': instance.isNetworkConnected,
      'chainId': instance.chainId,
      'chainName': instance.chainName,
      'isTestnet': instance.isTestnet,
      'isTargetChain': instance.isTargetChain,
      'blockNumber': instance.blockNumber.toString(),
      'gasPrice': instance.gasPrice.toString(),
      'accountList': instance.accountList,
      'selectedAccount': instance.selectedAccount,
      'ethersVersion': instance.ethersVersion,
      'taikoL1Address': instance.taikoL1Address,
      'l1StakingAddress': instance.l1StakingAddress,
      'mxcTokenAddress': instance.mxcTokenAddress,
      'zkCenterAddress': instance.zkCenterAddress,
      'zkCenterName2': instance.zkCenterName2,
      'stakingPoolInfo': instance.stakingPoolInfo,
      'userStakeStatus': instance.userStakeStatus,
      'ethBalance': instance.ethBalance,
      'mxcBalance': instance.mxcBalance,
      'grossReward': instance.grossReward.toString(),
      'grossRewardMxc': instance.grossRewardMxc,
      'minerCount': instance.minerCount,
    };
