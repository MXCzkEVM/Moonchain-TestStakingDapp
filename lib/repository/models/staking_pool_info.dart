import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'staking_pool_info.g.dart';

@JsonSerializable()
class StakingPoolInfo extends Equatable {
  const StakingPoolInfo({
    required this.totalAmount,
    required this.rewardBalance,
    required this.lastDepositRewardTime,
    required this.rewardBeginEpoch,
    required this.currentEpoch,
  });

  // properties
  final BigInt totalAmount;
  final BigInt rewardBalance;
  final DateTime lastDepositRewardTime;
  final BigInt rewardBeginEpoch;
  final BigInt currentEpoch;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory StakingPoolInfo.fromJson(Map<String, dynamic> json) =>
      _$StakingPoolInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StakingPoolInfoToJson(this);

  @override
  String toString() => 'StakingPoolInfo ${toJsonString()}';

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = StakingPoolInfo(
    totalAmount: BigInt.from(0),
    rewardBalance: BigInt.from(0),
    lastDepositRewardTime: DateTime.now(),
    rewardBeginEpoch: BigInt.from(0),
    currentEpoch:  BigInt.from(0),
    );

}
