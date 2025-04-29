import "dart:convert";
import "dart:async";

import "package:bloc/bloc.dart";
import "package:dapp/singletons/routes.dart";
import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:flutter/foundation.dart";

import "package:dapp/shared/ticker.dart";
import "package:dapp/repository/repository.dart";

import "../home.dart";

part "home_state.dart";
part "home_cubit.g.dart";

const kConfigFilename = "config.json";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.tickerCheck,
    required this.l1Repository,
    required this.localSettingRepos,
    required this.proverServiceRepos,
  }) : super(HomeState.initial) {
    debugPrint("HomeCubit Start tickers.");
    _tickerCheckSub = tickerCheck.tick().listen((_) => onTickerCheck());

    //
    if (l1Repository.connected) {
      skipTickerUpdate = true;
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
  bool skipTickerUpdate = true;

  @override
  Future<void> close() async {
    debugPrint("HomeCubit Stop tickers.");

    skipTickerUpdate = true;
    await _tickerCheckSub?.cancel();
    await Future.delayed(const Duration(milliseconds: 500));
    return super.close();
  }

  // Startup steps
  void _startup() async {
    debugPrint('_startup');
    if (!await l1Repository.connect()) {
      lastError = "Connect failed. ${l1Repository.lastError}";
    } else {
      await _updateState();
      Future.delayed(const Duration(microseconds: 100), () async{
        await _updateInfo();
        skipTickerUpdate = false;
      });
    }
  }

  //
  Future<bool> connectMetamask() async {
    if (!l1Repository.isEtherReady()) {
      lastError = "It seems metamask not supported/enabled.";
      return false;
    } else {
      skipTickerUpdate = true;
      emit(state.copyWith(waiting: true));
      Future.delayed(const Duration(milliseconds: 200), _startup);
      return true;
    }
  }

  // Events
  void onTickerCheck() async {
    if (!l1Repository.connected) {
    } else if (await l1Repository.isChainChanged()) {
      debugPrint('Chain changed.');
      // if (!await l1Repository.connect()) {
      //   lastError = "Connect failed. ${l1Repository.lastError}";
      // }
      l1Repository.disconnect();
      routes.popAndPushNamed(Routes.home);
    } else if (await l1Repository.isSignerChanged()) {
      debugPrint("signer changed");
      l1Repository.disconnect();
      routes.popAndPushNamed(Routes.home);
    } else if (!skipTickerUpdate) {
      await _updateInfo();
    }
  }

  //
  Future<void> onChainChanged(int aChainId) async {
    debugPrint("chainId: ${aChainId.toString()}");
    emit(state.copyWith(
      chainId: aChainId,
      chainName: l1Repository.chainName(),
      isTestnet: l1Repository.isTestnet(),
      blockNumber: BigInt.from(0),
    ));
  }

  Future<void> _updateState() async {
    // Read load setting
    final setting = await localSettingRepos.load(l1Repository.selectedAccount);

    // Setup prover service
    proverServiceRepos.setMainnet(l1Repository.isMainnet());
    proverServiceRepos.setWalletAddress(
        l1Repository.selectedAccount, setting.appToken);

    // set state
    emit(state.copyWith(
      accountList: l1Repository.accountList,
      selectedAccount: l1Repository.selectedAccount,
      isNetworkConnected: l1Repository.isEtherConnnected(),
      chainId: l1Repository.chainId,
      chainName: l1Repository.chainName(),
      isTestnet: l1Repository.isTestnet(),
      isTargetChain: l1Repository.isArbiturm(),
      ethersVersion: l1Repository.ethersVersion,
      taikoL1Address: l1Repository.taikoL1Address,
      l1StakingAddress: l1Repository.l1StakingAddress,
      mxcTokenAddress: l1Repository.mxcTokenAddress,
      zkCenterAddress: l1Repository.zkCenterAddress,
      zkCenterName2: l1Repository.zkCenterName2,
    ));
  }

  Future<void> _updateInfo() async {
    if (l1Repository.connected) {
      final info = await l1Repository.getStakingPoolInfo();
      var uiStakingPoolInfo = UiStakingPoolInfo.initial;
      if (info != null) {
        uiStakingPoolInfo = UiStakingPoolInfo(
          totalAmountMxc:
              l1Repository.weiToMxc(info.totalAmount).toStringAsFixed(5),
          rewardBalanceMxc:
              l1Repository.weiToMxc(info.rewardBalance).toStringAsFixed(5),
          lastDepositRewardTime: info.lastDepositRewardTime,
          rewardBeginEpoch:
              '${info.rewardBeginEpoch} (${l1Repository.epochToString(info.rewardBeginEpoch)})',
          currentEpoch:
              '${info.currentEpoch} (${l1Repository.epochToString(info.currentEpoch)})',
        );
      }

      final userStakeStatus = await l1Repository.stakeGetStatus();
      final miningGroupTokenId = await l1Repository.miningGroupGetId();
      var stakingGroupId =
          userStakeStatus == null ? BigInt.zero : userStakeStatus.stakingGroup;
      var isGroupLeader = false;
      if (miningGroupTokenId != null) {
        stakingGroupId = miningGroupTokenId;
        isGroupLeader = true;
      }

      final lastClaimedEpoch = userStakeStatus == null
          ? BigInt.zero
          : userStakeStatus.lastClaimedEpoch;
      final adjustedLastClaim = lastClaimedEpoch + BigInt.from(1);
      String strLastClaimedEpoch =
          '$adjustedLastClaim (${l1Repository.epochToString(adjustedLastClaim)})';
      if (userStakeStatus == null) {
        strLastClaimedEpoch = '';
      } else if ((info != null) && (adjustedLastClaim > info.currentEpoch)) {
        strLastClaimedEpoch = '$adjustedLastClaim (Penalty applied)';
      }

      var uiStakingUserState = UiUserStakeStatus.initial;
      if (userStakeStatus != null) {
        uiStakingUserState = UiUserStakeStatus(
          stakingBalancesMxc: l1Repository
              .weiToMxc(userStakeStatus.stakedAmount)
              .toStringAsFixed(5),
          lastClaimedEpoch: lastClaimedEpoch,
          strLastClaimedEpoch: strLastClaimedEpoch,
          withdrawalRequestEpoch: userStakeStatus.withdrawalRequestEpoch ==
                  BigInt.zero
              ? 'Not yet'
              : '${userStakeStatus.withdrawalRequestEpoch} (${l1Repository.epochToString(userStakeStatus.withdrawalRequestEpoch)})',
          stakingGroupId: stakingGroupId,
          isGroupLeader: isGroupLeader,
        );
      }

      final (ethBalance, mxcBalance) = await l1Repository.getBalances();

      final grossReward = await l1Repository.stakeGetGrossReward();
      final grossRewardMxc =
          l1Repository.weiToMxc(grossReward ?? BigInt.zero).toStringAsFixed(5);

      final minerList = await proverServiceRepos.getMinerList();

      emit(state.copyWith(
        waiting: false,
        blockNumber: await l1Repository.getBlockNumber(),
        stakingPoolInfo: uiStakingPoolInfo,
        userStakeStatus: uiStakingUserState,
        ethBalance: l1Repository.weiToMxc(ethBalance).toStringAsFixed(5),
        mxcBalance: l1Repository.weiToMxc(mxcBalance).toStringAsFixed(5),
        grossReward: grossReward,
        grossRewardMxc: grossRewardMxc,
        minerCount: minerList.length,
      ));
    } else {
      emit(state.copyWith(
        waiting: false,
      ));
    }
  }
}
