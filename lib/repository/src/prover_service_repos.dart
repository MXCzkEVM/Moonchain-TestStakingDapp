import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../repository.dart';

class ProverServiceRepos {
  ProverServiceRepos();

  String lastError = '';

  String walletAddress = '';
  String appToken = '';
  bool isMainnet = false;
  String baseUrl = '';

  void setMainnet(bool aIsMainnet) {
    isMainnet = aIsMainnet;
    if (isMainnet) {
      baseUrl = 'https://prover-manager.moonchain.com';
    } else {
      baseUrl = 'https://geneva-prover-manager.moonchain.com';
    }
  }

  void setWalletAddress(String aWalletAddress, String aToken) {
    walletAddress = aWalletAddress.toLowerCase();
    appToken = aToken;
  }

  Future<List<AppMinerListItem>> getMinerList() async {
    List<AppMinerListItem> retList = [];

    try {
      final baseUri = Uri.parse(baseUrl);

      final Map<String, String> requestHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $appToken',
      };

      final urlList = baseUri.replace(
          path: '${baseUri.path}/./app/minerList/$walletAddress',
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString()
          }).normalizePath();
      debugPrint('HTTP GET ${urlList.path}');
      final httpResp = await http.get(urlList, headers: requestHeaders);
      if (httpResp.statusCode != 200) {
        debugPrint('getMinerList failed. statusCode=${httpResp.statusCode}');
      } else {
        final appResp = AppMinerListResp.fromJson(jsonDecode(httpResp.body));

        if (appResp.ret != 0) {
          throw Exception('ret=${appResp.ret}, message=${appResp.message}');
        }

        for (var miner in appResp.result.minerList) {
          retList.add(
            AppMinerListItem(
              instanceId: miner.instanceId,
              lastPing: miner.lastPing,
              online: miner.online,
            ),
          );
        }
      }
      debugPrint('getMinerList: ${retList.length} miner loaded.');
    } on Exception catch (aError) {
      debugPrint('Error: getMinerList failed. ${aError.toString()}');
    }

    return retList;
  }
}
