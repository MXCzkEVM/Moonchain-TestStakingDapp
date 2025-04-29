import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_miner_list_resp.g.dart';

@JsonSerializable()
class AppMinerListItem extends Equatable{
  const AppMinerListItem({
    required this.instanceId,
    required this.lastPing,
    required this.online,
  });

  final int instanceId;
  final String lastPing;
  final double online;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory AppMinerListItem.fromJson(Map<String, dynamic> json) =>
      _$AppMinerListItemFromJson(json);

  Map<String, dynamic> toJson() => _$AppMinerListItemToJson(this);

  @override
  String toString() => 'AppMinerListItem ${toJsonString()}';

  String toJsonString() => jsonEncode(toJson());
}

@JsonSerializable()
class AppMinerListResult extends Equatable {
  const AppMinerListResult({
    required this.count,
    required this.minerList,
  });

  final int count;
  final List<AppMinerListItem> minerList;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory AppMinerListResult.fromJson(Map<String, dynamic> json) =>
      _$AppMinerListResultFromJson(json);

  Map<String, dynamic> toJson() => _$AppMinerListResultToJson(this);

  @override
  String toString() => 'AppMinerListResult ${toJsonString()}';

  String toJsonString() => jsonEncode(toJson());
}



@JsonSerializable()
class AppMinerListResp extends Equatable {
  const AppMinerListResp({
    required this.ret,
    required this.message,
    required this.result,
  });

  // properties
  final int ret;
  final String message;
  final AppMinerListResult result;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory AppMinerListResp.fromJson(Map<String, dynamic> json) =>
      _$AppMinerListRespFromJson(json);

  Map<String, dynamic> toJson() => _$AppMinerListRespToJson(this);

  @override
  String toString() => 'AppMinerListResp ${toJsonString()}';

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = AppMinerListResp(
    ret: -1,
    message: 'UNKNOWN',
    result: AppMinerListResult(count: 0, minerList: []),
  );
}
