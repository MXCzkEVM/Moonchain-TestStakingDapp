import "dart:convert";
import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:flutter/foundation.dart";

import "package:dapp/shared/ticker.dart";
import "package:dapp/repository/repository.dart";
import "package:dapp/singletons/routes.dart";

import "../stake.dart";

part "stake_state.dart";
part "stake_cubit.g.dart";

class StakeCubit extends Cubit<StakeState> {
  StakeCubit({
    required this.tickerCheck,
    required this.l1Repository,
  }) : super(StakeState.initial) {
    debugPrint("StakeCubit Start tickers.");
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
    debugPrint("StakeCubit Stop tickers.");

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
      final userStakeStatus = await l1Repository.stakeGetStatus();
      final (ethBalance, mxcBalance) = await l1Repository.getBalances();

      emit(state.copyWith(
        waiting: false,
        selectedAccount: l1Repository.selectedAccount,
        totalBalanceMxc: userStakeStatus == null
            ? ''
            : l1Repository
                .weiToMxc(userStakeStatus.stakedAmount)
                .toStringAsFixed(5),
        ethBalance: l1Repository.weiToMxc(ethBalance).toStringAsFixed(5),
        mxcBalance: l1Repository.weiToMxc(mxcBalance).toStringAsFixed(5),
        minDeposit: l1Repository.minDeposit,
        minDepositMxc: l1Repository.weiToMxc(l1Repository.minDeposit).toStringAsFixed(5),
      ));
    }
  }

  //
  void setStakeAmount(String aValue) {
    debugPrint('setStakeAmount: $aValue');
    final value = double.tryParse(aValue) ?? 0;
    final strValue = value.toStringAsFixed(5);
    emit(state.copyWith(stakeAmount: strValue));
  }

  //
  Future<bool> startStaking() async {
    final amount = double.tryParse(state.stakeAmount) ?? 0;
    if (amount == 0) {
      lastError = 'Invalid amount ${amount.toString()}.';
      return false;
    }
    emit(state.copyWith(
        waiting: true,
        waitingMessage:
            "Staking in progress ...\n  Approving for MXC transfer...",
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (approveRet, approveHash) = await l1Repository.approve(amount);
      if (!approveRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult: "Approve failed.\n${l1Repository.lastError}"));
      } else {
        emit(state.copyWith(
          waitingMessage: "Staking in progress ...\n  Staking...",
        ));

        final (stakeRet, stakeHash) = await l1Repository.stakeDeposit(amount);
        if (!stakeRet) {
          emit(state.copyWith(
              waiting: false,
              transactionInProgress: false,
              transactionDone: true,
              transactionResult:
                  "Staking failed.\n${l1Repository.lastError}"));
        } else {
          emit(state.copyWith(
              waiting: false,
              transactionInProgress: false,
              transactionDone: true,
              transactionResult: "Staking success.\n  Approve Txn $approveHash\n  Stake Txn $stakeHash"));
        }
      }
    });
    return true;
  }
}
