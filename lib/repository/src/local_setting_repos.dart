import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository.dart';

class LocalSettingRepos {
  LocalSettingRepos();

  String lastError = '';

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  Future<WalletSetting> load(String aWalletAddress) async {
    final String key = 'W_${aWalletAddress.toLowerCase()}';
    final String? strValue = await asyncPrefs.getString(key);
    var ret = WalletSetting.initial;
    try {
      if (strValue != null) {
        debugPrint('LocalSettingRepos load $aWalletAddress success.');
        final setting = WalletSetting.fromJson(jsonDecode(strValue));
        ret = setting;
      }
      else {
        debugPrint('LocalSettingRepos load $aWalletAddress failed. Empty string.');
      }
    } catch (aError) {
      print('LocalSettingRepos.load error. $aError');
    }

    return ret;
  }

  Future<bool> save(String aWalletAddress, WalletSetting aSetting) async {
    final String key = 'W_${aWalletAddress.toLowerCase()}';
    final String strValue = aSetting.toJsonString();
    await asyncPrefs.setString(key, strValue);
    debugPrint('LocalSettingRepos save success.');
    return true;
  }

}
