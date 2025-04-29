import "dart:convert";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";

part "ui_user_stake_status.g.dart";

@JsonSerializable()
class UiUserStakeStatus extends Equatable {
  UiUserStakeStatus({
    required this.stakingBalancesMxc,
    required this.lastClaimedEpoch,
    required this.strLastClaimedEpoch,
    required this.withdrawalRequestEpoch,
    required this.stakingGroupId,
    required this.isGroupLeader,
  });

  // properties
  final DateTime timestamp = DateTime.now();
  final String stakingBalancesMxc;
  final BigInt lastClaimedEpoch;
  final String strLastClaimedEpoch;
  final String withdrawalRequestEpoch;
  final BigInt stakingGroupId;
  final bool isGroupLeader;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory UiUserStakeStatus.fromJson(Map<String, dynamic> json) =>
      _$UiUserStakeStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UiUserStakeStatusToJson(this);

  @override
  String toString() => "UiUserStakeStatus $timestamp";

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = UiUserStakeStatus(
    stakingBalancesMxc: '',
    lastClaimedEpoch: BigInt.zero,
    strLastClaimedEpoch: '',
    withdrawalRequestEpoch: '',
    stakingGroupId: BigInt.zero,
    isGroupLeader: false,
  );
}
