import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_setting.g.dart';

@JsonSerializable()
class WalletSetting extends Equatable {
  const WalletSetting({
    required this.appToken,
  });

  // properties
  final String appToken;

  //
  @override
  List<Object> get props => [toJsonString()];

  //
  factory WalletSetting.fromJson(Map<String, dynamic> json) =>
      _$WalletSettingFromJson(json);

  Map<String, dynamic> toJson() => _$WalletSettingToJson(this);

  @override
  String toString() => 'WalletSetting ${toJsonString()}';

  String toJsonString() => jsonEncode(toJson());

  //
  static final initial = WalletSetting(
    appToken: '',
  );
}
