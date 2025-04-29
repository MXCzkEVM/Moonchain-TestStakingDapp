import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:dapp/app.dart';
import 'package:json_theme/json_theme.dart';
import 'package:dapp/singletons/appdata.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter/services.dart'; // For rootBundle
import 'dart:convert'; // For jsonDecode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  Bloc.observer = const AppBlocObserver();

  // Remove loading message
  final mainMessage = js.context['mainMessage']; // Get web global object (window.mainMessage)
  mainMessage.innerHtml = '';

  // For debugging
  if (kDebugMode) {
    // For debugging
    debugPrint('Debug mode.');
  } else {
    // For Release mode
    debugPrint('Release mode.');
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Load Theme https://appainter.dev
  try {
    final themeStr = await rootBundle
        .loadString('assets/data/appainter_theme.json', cache: false);
    final themeJson = jsonDecode(themeStr);
    appData.theme = ThemeDecoder.decodeThemeData(themeJson)!;
  } on Exception catch (e) {
    appData.startupError = 'Load theme failed.\n${e.toString()}';
  }

  // Load contract info
  try {
    final infoStr = await rootBundle
        .loadString('assets/data/contract_info.json', cache: false);
    final infoJson = jsonDecode(infoStr);
    appData.mainnetContractInfo.taikoL1Address =
        infoJson['mainnet']['taikoL1Address'];
    appData.testnetContractInfo.taikoL1Address =
        infoJson['testnet']['taikoL1Address'];
  } catch (aError) {
    appData.startupError = 'Load Contract Info failed.\n${aError.toString()}';
  }

  // Get app info
  try {
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appData.name = 'Test Staking';
    appData.packageName = packageInfo.packageName;
    appData.version = packageInfo.version;
    appData.buildNumber = packageInfo.buildNumber;
  } on UnimplementedError catch (e) {
    appData.startupError = 'Get app info failed.\n${e.toString()}';
  } on Exception catch (e) {
    appData.startupError = 'Get app info failed.\n${e.toString()}';
  }

  runApp(const App());
}
