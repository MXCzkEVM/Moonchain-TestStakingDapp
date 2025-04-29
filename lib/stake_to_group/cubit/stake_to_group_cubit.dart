import "dart:convert";
import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:flutter/foundation.dart";

import "package:dapp/shared/ticker.dart";
import "package:dapp/repository/repository.dart";
import "package:dapp/singletons/routes.dart";

import "../stake_to_group.dart";

part "stake_to_group_state.dart";
part "stake_to_group_cubit.g.dart";

class StakeToGroupCubit extends Cubit<StakeToGroupState> {
  StakeToGroupCubit({
    required this.tickerCheck,
    required this.l1Repository,
    required this.localSettingRepos,
    required this.proverServiceRepos,
  }) : super(StakeToGroupState.initial) {
    debugPrint("StakeToGroupCubit Start tickers.");
    _tickerCheckSub = tickerCheck.tick().listen((_) => onTickerCheck());

    // Back to Home if not connected.
    if (!l1Repository.connected) {
      Future.delayed(const Duration(milliseconds: 100), routes.backToHome);
    } else {
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 200), _startup);
    }
  }

  final Ticker tickerCheck;

  StreamSubscription? _tickerCheckSub;
  String lastError = "";

  final L1Repository l1Repository;
  final LocalSettingRepos localSettingRepos;
  final ProverServiceRepos proverServiceRepos;

  @override
  Future<void> close() async {
    debugPrint("StakeToGroupCubit Stop tickers.");

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

  // Startup steps
  void _startup() async {
    // Read load setting
    final setting = await localSettingRepos.load(l1Repository.selectedAccount);

    // Setup prover service
    proverServiceRepos.setMainnet(l1Repository.isMainnet());
    proverServiceRepos.setWalletAddress(l1Repository.selectedAccount, setting.appToken);

    //
    final userStakeStatus = await l1Repository.stakeGetStatus();
    final stakingGroupId =
        userStakeStatus == null ? BigInt.zero : userStakeStatus.stakingGroup;

    if (stakingGroupId == BigInt.zero) {
      await loadGroupList();
    }
    else {
      // Already in group
      emit(state.copyWith(selectedGroup: await getGroupInfo(stakingGroupId), inGroup: true));
    }

    Future.delayed(const Duration(milliseconds: 100), _updateState);
  }

  // Periodic update
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
        minDepositMxc:
            l1Repository.weiToMxc(l1Repository.minDeposit).toStringAsFixed(5),
      ));
    }
  }

  // Load list of group
  Future<bool> loadGroupList() async {
    final total = await l1Repository.miningGroupGetTotal();
    debugPrint('loadGroupList: total=$total');
    if (total == null) return false;

    // Max 10 items
    int listCount = 10;
    if (total < BigInt.from(listCount)) listCount = total.toInt();

    // Pick groups
    List<BigInt> groupIdList = [];
    for (int i = 0; i < listCount; i++) {
      final groupId =
          await l1Repository.miningGroupGetIdByIndex(BigInt.from(i));
      if (groupId != null) groupIdList.add(groupId);
    }

    // Get group detail
    List<UiGroupInfo> groupInfoList = [];
    for (int i = 0; i < groupIdList.length; i++) {
      groupInfoList.add(await getGroupInfo(groupIdList[i]));
    }

    //
    emit(state.copyWith(groupList: groupInfoList, inGroup: false));

    return true;
  }

  // Get Group info
  Future<UiGroupInfo> getGroupInfo(BigInt aGroupId) async {
    final groupOwner = await l1Repository.miningGroupGetLeader(aGroupId);
    final groupMemberCount =
        await l1Repository.miningGroupGetMemberCount(aGroupId);
    return UiGroupInfo(
      id: aGroupId,
      strId: aGroupId.toString(),
      owner: groupOwner ?? '',
      memberCount: groupMemberCount == null ? '' : groupMemberCount.toString(),
    );
  }

  // Select a group
  void selectGroup(int aIdx) {
    if ((aIdx < 0) || (aIdx >= state.groupList.length)) {
      emit(state.copyWith(selectedGroup: UiGroupInfo.initial));
    } else {
      emit(state.copyWith(selectedGroup: state.groupList[aIdx]));
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
    if (state.selectedGroup == UiGroupInfo.initial) {
      lastError = 'Mining group not selected.';
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

        final (stakeRet, stakeHash) =
            await l1Repository.stakeToGroup(state.selectedGroup.id, amount);
        if (!stakeRet) {
          emit(state.copyWith(
              waiting: false,
              transactionInProgress: false,
              transactionDone: true,
              transactionResult: "Staking failed.\n${l1Repository.lastError}"));
        } else {
          emit(state.copyWith(
              waiting: false,
              transactionInProgress: false,
              transactionDone: true,
              transactionResult:
                  "Staking success.\n  Approve Txn $approveHash\n  Stake Txn $stakeHash"));
        }
      }
    });
    return true;
  }
}
