import "dart:convert";
import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:flutter/foundation.dart";

import "package:dapp/shared/ticker.dart";
import "package:dapp/repository/repository.dart";
import "package:dapp/singletons/routes.dart";

import "../miner.dart";

part "miner_state.dart";
part "miner_cubit.g.dart";

class MinerCubit extends Cubit<MinerState> {
  MinerCubit({
    required this.tickerCheck,
    required this.l1Repository,
    required this.localSettingRepos,
    required this.proverServiceRepos,
  }) : super(MinerState.initial) {
    debugPrint("MinerCubit Start tickers.");
    _tickerCheckSub = tickerCheck.tick().listen((_) => onTickerCheck());

    if (!l1Repository.connected) {
      Future.delayed(const Duration(milliseconds: 100), routes.backToHome);
    } else {
      skipTickerUpdate = true;
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 100), startup);
    }
  }

  final Ticker tickerCheck;

  StreamSubscription? _tickerCheckSub;
  String lastError = "";

  final L1Repository l1Repository;
  final LocalSettingRepos localSettingRepos;
  final ProverServiceRepos proverServiceRepos;

  bool skipTickerUpdate = true;

  @override
  Future<void> close() async {
    debugPrint("MinerCubit Stop tickers.");

    skipTickerUpdate = true;
    await _tickerCheckSub?.cancel();
    await Future.delayed(const Duration(milliseconds: 500));
    return super.close();
  }

  //
  void startup() async {
    final setting = await localSettingRepos.load(l1Repository.selectedAccount);
    debugPrint('setting=${setting.toJsonString()}');
    emit(state.copyWith(appToken: setting.appToken));
    Future.delayed(const Duration(milliseconds: 100), () async {
      await _updateState();
      skipTickerUpdate = false;
    });
  }

  // Events
  void onTickerCheck() async {
    if ((await l1Repository.isChainChanged()) ||
        (await l1Repository.isSignerChanged())) {
      l1Repository.disconnect();
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 100), routes.backToHome);
    } else if (!skipTickerUpdate) {
      _updateInfo();
    }
  }

  //
  Future<void> _updateState() async {
    // Read load setting
    final setting = await localSettingRepos.load(l1Repository.selectedAccount);

    // Setup prover service
    proverServiceRepos.setMainnet(l1Repository.isMainnet());
    proverServiceRepos.setWalletAddress(
        l1Repository.selectedAccount, setting.appToken);

    // set state
    emit(state.copyWith(
      selectedAccount: l1Repository.selectedAccount,
    ));
  }

  //
  Future<void> _updateInfo() async {
    if (l1Repository.connected) {
      final cloudMinerList = await proverServiceRepos.getMinerList();
      List<UiMinerInfo> minerList = [];
      for (var miner in cloudMinerList) {
        minerList.add(
          UiMinerInfo(
              instanceId: miner.instanceId.toString(),
              lastPing: miner.lastPing.isEmpty ? 'Never' : miner.lastPing,
              online: '${(miner.online * 100).toStringAsFixed(2)}%'),
        );
      }
      emit(state.copyWith(
        waiting: false,
        minerCount: minerList.length,
        minerList: minerList,
      ));
    } else {
      emit(state.copyWith(
        waiting: false,
      ));
    }
  }

  //
  void setAppToken(String aValue) {
    emit(state.copyWith(appToken: aValue));
  }

  //
  Future<bool> saveSetting() async {
    final oldSetting =
        await localSettingRepos.load(l1Repository.selectedAccount);
    final newSettiing = WalletSetting(
      appToken: state.appToken,
    );
    await localSettingRepos.save(l1Repository.selectedAccount, newSettiing);

    return true;
  }
}
