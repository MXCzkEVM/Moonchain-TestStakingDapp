import "dart:convert";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";

part "ui_miner_info.g.dart";

@JsonSerializable()
class UiMinerInfo extends Equatable {
  UiMinerInfo({
    required this.instanceId,
    required this.lastPing,
    required this.online,
  });

  // properties
  final DateTime timestamp = DateTime.now();
  final String instanceId;
  final String lastPing;
  final String online;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory UiMinerInfo.fromJson(Map<String, dynamic> json) =>
      _$UiMinerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UiMinerInfoToJson(this);

  @override
  String toString() => "UiMinerInfo $timestamp";

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = UiMinerInfo(
    instanceId: '',
    lastPing: '',
    online: '',
  );
}
