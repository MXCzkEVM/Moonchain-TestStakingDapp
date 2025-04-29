import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_stake_status.g.dart';

@JsonSerializable()
class UserStakeStatus extends Equatable {
  const UserStakeStatus({
    required this.stakingGroup,
    required this.stakedAmount,
    required this.lastClaimedEpoch,
    required this.withdrawalRequestEpoch,
  });

  // properties
  final BigInt stakingGroup;
  final BigInt stakedAmount;
  final BigInt lastClaimedEpoch;
  final BigInt withdrawalRequestEpoch;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory UserStakeStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStakeStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UserStakeStatusToJson(this);

  @override
  String toString() => 'UserStakeStatus $stakingGroup $stakedAmount $lastClaimedEpoch $withdrawalRequestEpoch';

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = UserStakeStatus(
    stakingGroup: BigInt.from(0),
    stakedAmount: BigInt.from(0),
    lastClaimedEpoch: BigInt.from(0),
    withdrawalRequestEpoch: BigInt.from(0),
    );

}
