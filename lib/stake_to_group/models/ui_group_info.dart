import "dart:convert";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";

part "ui_group_info.g.dart";

@JsonSerializable()
class UiGroupInfo extends Equatable {
  UiGroupInfo({
    required this.id,
    required this.strId,
    required this.owner,
    required this.memberCount,
  });

  // properties
  final DateTime timestamp = DateTime.now();
  final BigInt id;
  final String strId;
  final String owner;
  final String memberCount;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory UiGroupInfo.fromJson(Map<String, dynamic> json) =>
      _$UiGroupInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UiGroupInfoToJson(this);

  @override
  String toString() => "UiGroupInfo $timestamp";

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = UiGroupInfo(
    id: BigInt.zero,
    strId: '',
    owner: '',
    memberCount: '',
  );
}
