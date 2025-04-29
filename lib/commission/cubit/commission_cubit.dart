import 'dart:convert';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../commission.dart';

part 'commission_state.dart';
part 'commission_cubit.g.dart';

class CommissionCubit extends Cubit<CommissionState> {
  CommissionCubit({
    required this.tickerCheck,
    required this.l1Repository,
  }) : super(CommissionState.initial) {
    debugPrint('CommissionCubit Start tickers.');
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
    debugPrint('CommissionCubit Stop tickers.');

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
      final miningGroupTokenId = await l1Repository.miningGroupGetId();

      final (ethBalance, mxcBalance) = await l1Repository.getBalances();
      final info = await l1Repository.getStakingPoolInfo();

      final totalBalanceMxc = info == null
          ? ''
          : l1Repository.weiToMxc(info.totalAmount).toStringAsFixed(5);
      final rewardBeginEpoch = info == null
          ? ''
          : '${info.rewardBeginEpoch} (${l1Repository.epochToString(info.rewardBeginEpoch)})';
      final currentEpoch = info == null
          ? ''
          : '${info.currentEpoch} (${l1Repository.epochToString(info.currentEpoch)})';
      final lastClaimedEpoch = userStakeStatus == null
          ? ''
          : '${userStakeStatus.lastClaimedEpoch + BigInt.from(1)} (${l1Repository.epochToString(userStakeStatus.lastClaimedEpoch + BigInt.from(1))})';
      final stakingBalancesMxc = userStakeStatus == null
          ? ''
          : l1Repository
              .weiToMxc(userStakeStatus.stakedAmount)
              .toStringAsFixed(5);
      final stakingBalances =
          userStakeStatus == null ? BigInt.zero : userStakeStatus.stakedAmount;
      final comissionAmount = await l1Repository.stakeGetCommission();
      final comissionAmountMxc =
          l1Repository.weiToMxc(comissionAmount ?? BigInt.zero).toStringAsFixed(5);

      emit(state.copyWith(
        waiting: false,
        selectedAccount: l1Repository.selectedAccount,
        totalBalanceMxc: totalBalanceMxc,
        ethBalance: l1Repository.weiToMxc(ethBalance).toStringAsFixed(5),
        mxcBalance: l1Repository.weiToMxc(mxcBalance).toStringAsFixed(5),
        currentEpoch: currentEpoch,
        rewardBeginEpoch: rewardBeginEpoch,
        lastClaimedEpoch: lastClaimedEpoch,
        stakingBalancesMxc: stakingBalancesMxc,
        stakingBalances: stakingBalances,
        comissionAmount: comissionAmount,
        comissionAmountMxc: comissionAmountMxc,
      ));
    }
  }

  //
  Future<bool> startClaim() async {
    emit(state.copyWith(
        waiting: true,
        waitingMessage: 'Claim in progress ...\n',
        transactionInProgress: true,
        transactionDone: false,
        transactionResult: ''));

    Future.delayed(const Duration(milliseconds: 100), () async {
      final (claimRet, claimHash) = await l1Repository.stakeClaimCommission();
      if (!claimRet) {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Claim Commission failed.\n${l1Repository.lastError}'));
      } else {
        emit(state.copyWith(
            waiting: false,
            transactionInProgress: false,
            transactionDone: true,
            transactionResult:
                'Claim Commission success.\n  Claim Txn $claimHash'));
      }
    });
    return true;
  }
}
