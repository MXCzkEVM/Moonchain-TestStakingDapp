import "dart:convert";
import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:flutter/foundation.dart";

import "package:dapp/shared/ticker.dart";
import "package:dapp/repository/repository.dart";
import "package:dapp/singletons/routes.dart";

import "../create_group.dart";

part "create_group_state.dart";
part "create_group_cubit.g.dart";

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit({
    required this.tickerCheck,
    required this.l1Repository,
  }) : super(CreateGroupState.initial) {
    debugPrint("CreateGroupCubit Start tickers.");
    _tickerCheckSub = tickerCheck.tick().listen((_) => onTickerCheck());

    if (!l1Repository.connected) {
      Future.delayed(const Duration(milliseconds: 100), routes.backToHome);
    } else {
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 200), _updateState);
    }
  }

  final Ticker tickerCheck;

  StreamSubscription? _tickerCheckSub;
  String lastError = "";

  final L1Repository l1Repository;

  @override
  Future<void> close() async {
    debugPrint("CreateGroupCubit Stop tickers.");

    await _tickerCheckSub?.cancel();
    await Future.delayed(const Duration(milliseconds: 500));
    return super.close();
  }

  // Events
  void onTickerCheck() async {
    if ((await l1Repository.isChainChanged()) || (await l1Repository.isSignerChanged())) {
      l1Repository.disconnect();
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 100), routes.backToHome);
    } else {
      _updateState();
    }
  }

  //
  void _updateState() async {
    if ((l1Repository.connected) && (!state.transactionInProgress)) {
      final (ethBalance, mxcBalance) = await l1Repository.getBalances();

      emit(state.copyWith(
        waiting: false,
        selectedAccount: l1Repository.selectedAccount,
        ethBalance: l1Repository.weiToMxc(ethBalance).toStringAsFixed(5),
        mxcBalance: l1Repository.weiToMxc(mxcBalance).toStringAsFixed(5),
        minDeposit: l1Repository.minDeposit,
        minDepositMxc: l1Repository.weiToMxc(l1Repository.minDeposit).toStringAsFixed(5),
      ));
    }
  }

  //
  Future<bool> startCreateGroup() async {
    emit(state.copyWith(
        waiting: true,
        waitingMessage: 'Create group in progress ...\n',
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (createRet, createHash) = await l1Repository.creatGroup();
      if (!createRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Create group failed.\n${l1Repository.lastError}'));
      } else {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Create group success.\n  Claim Txn $createHash'));
      }
    });
    return true;
  }
}
