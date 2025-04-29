import "dart:convert";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";

part "ui_staking_pool_info.g.dart";

@JsonSerializable()
class UiStakingPoolInfo extends Equatable {
  UiStakingPoolInfo({
    required this.totalAmountMxc,
    required this.rewardBalanceMxc,
    required this.lastDepositRewardTime,
    required this.rewardBeginEpoch,
    required this.currentEpoch,
  });

  // properties
  final DateTime timestamp = DateTime.now();
  final String totalAmountMxc;
  final String rewardBalanceMxc;
  final DateTime lastDepositRewardTime;
  final String rewardBeginEpoch;
  final String currentEpoch;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory UiStakingPoolInfo.fromJson(Map<String, dynamic> json) =>
      _$UiStakingPoolInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UiStakingPoolInfoToJson(this);

  @override
  String toString() => "UiStakingPoolInfo $timestamp";

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = UiStakingPoolInfo(
    totalAmountMxc: '',
    rewardBalanceMxc: '',
    lastDepositRewardTime: DateTime.now(),
    rewardBeginEpoch: '',
    currentEpoch: '',
    );

}
