import 'dart:convert';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../withdraw.dart';

part 'withdraw_state.dart';
part 'withdraw_cubit.g.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  WithdrawCubit({
    required this.tickerCheck,
    required this.l1Repository,
  }) : super(WithdrawState.initial) {
    debugPrint('WithdrawCubit Start tickers.');
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
  String lastError = '';

  final L1Repository l1Repository;

  @override
  Future<void> close() async {
    debugPrint('WithdrawCubit Stop tickers.');

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

      final info = await l1Repository.getStakingPoolInfo();

      final currentEpoch = info == null
          ? ''
          : '${info.currentEpoch} (${l1Repository.epochToString(info.currentEpoch)})';

      final stakingBalancesMxc = userStakeStatus == null
          ? ''
          : l1Repository
              .weiToMxc(userStakeStatus.stakedAmount)
              .toStringAsFixed(5);
      final withdrawalRequestEpoch = (userStakeStatus == null)
          ? BigInt.zero
          : userStakeStatus.withdrawalRequestEpoch;

      final strWithdrawalRequestEpoch = withdrawalRequestEpoch == BigInt.zero
          ? 'Not yet'
          : '$withdrawalRequestEpoch (${l1Repository.epochToString(withdrawalRequestEpoch)})';
      final stakingBalances =
          userStakeStatus == null ? BigInt.zero : userStakeStatus.stakedAmount;

      final withDrawLockEpoch = l1Repository.withDrawLockEpoch;
      final grossReward = await l1Repository.stakeGetGrossReward();
      final grossRewardMxc = l1Repository
          .weiToMxc(grossReward ?? BigInt.zero)
          .toStringAsFixed(5);

      bool isLocked = true;
      if ((info != null) && (withdrawalRequestEpoch > BigInt.zero)) {
        if (info.currentEpoch >= (withdrawalRequestEpoch + withDrawLockEpoch)) {
          isLocked = false;
        }
      }

      emit(state.copyWith(
        waiting: false,
        selectedAccount: l1Repository.selectedAccount,
        ethBalance: l1Repository.weiToMxc(ethBalance).toStringAsFixed(5),
        mxcBalance: l1Repository.weiToMxc(mxcBalance).toStringAsFixed(5),
        currentEpoch: currentEpoch,
        stakingBalancesMxc: stakingBalancesMxc,
        withdrawalRequestEpoch: withdrawalRequestEpoch,
        strWithdrawalRequestEpoch: strWithdrawalRequestEpoch,
        stakingBalances: stakingBalances,
        withDrawLockEpoch: withDrawLockEpoch,
        isLocked: isLocked,
        grossReward: grossReward,
        grossRewardMxc: grossRewardMxc,
      ));
    }
  }

  //
  Future<bool> makeRequst() async {
    if (state.stakingBalances.compareTo(BigInt.zero) <= 0) {
      lastError = 'Invalid staked amount. ${state.stakingBalancesMxc} MXC.';
      return false;
    }
    emit(state.copyWith(
        waiting: true,
        waitingMessage: 'Request in progress ...\n',
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (requestRet, claimHash) = await l1Repository.stakeRequestWithdraw(false);
      if (!requestRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Make Request failed.\n${l1Repository.lastError}'));
      } else {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Make Request success.\n  Claim Txn $claimHash'));
      }
    });
    return true;
  }

  //
  Future<bool> cancelRequst() async {
    if (state.stakingBalances.compareTo(BigInt.zero) <= 0) {
      lastError = 'Invalid staked amount. ${state.stakingBalancesMxc} MXC.';
      return false;
    }
    emit(state.copyWith(
        waiting: true,
        waitingMessage: 'Cancel in progress ...\n',
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (requestRet, claimHash) = await l1Repository.stakeRequestWithdraw(true);
      if (!requestRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Cancel Request failed.\n${l1Repository.lastError}'));
      } else {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Cancel Request success.\n  Claim Txn $claimHash'));
      }
    });
    return true;
  }

  //
  Future<bool> withdraw() async {
    if (state.withdrawalRequestEpoch == BigInt.zero) {
      lastError = 'Request not make yet.';
      return false;
    }
    emit(state.copyWith(
        waiting: true,
        waitingMessage: 'Withdraw in progress ...\n',
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (requestRet, claimHash) = await l1Repository.stakeWithdraw();
      if (!requestRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult: 'Withdraw failed.\n${l1Repository.lastError}'));
      } else {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult: 'Withdraw success.\n  Claim Txn $claimHash'));
      }
    });
    return true;
  }
}
