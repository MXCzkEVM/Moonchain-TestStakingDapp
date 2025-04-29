import "package:flutter/material.dart";

class ContractInfo {
  ContractInfo() {
    taikoL1Address = '';
  }

  late String taikoL1Address;
}

class AppData {
  static final AppData _appData = AppData._internal();

  // Load theme JSON generated at https://appainter.dev/#/
  ThemeData theme = ThemeData();

  // App info
  String name = "APP";
  String version = "0.0.0";
  String buildNumber = "0";
  String packageName = "APP";

  // Contract Info
  ContractInfo testnetContractInfo = ContractInfo();
  ContractInfo mainnetContractInfo = ContractInfo();

  // Startup error
  String? startupError;

  //
  factory AppData () {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();
