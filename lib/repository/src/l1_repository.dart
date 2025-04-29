import 'dart:js_interop';
import 'dart:js_util';
import 'dart:js' as js;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:intl/intl.dart';

import 'package:dapp/singletons/appdata.dart';

import '../repository.dart';
import './contracts/contracts.dart';
import './moonchain_utils.dart';

class L1Repository {
  L1Repository();

  String lastError = '';

  String ethersVersion = '';
  int chainId = 0;
  List<String> accountList = [];
  String taikoL1Address = '';
  String l1StakingAddress = '';
  String mxcTokenAddress = '';
  String zkCenterAddress = '';

  BrowserProvider? web3;
  Contract? taikoL1Contract;
  Contract? l1StakingContract;
  Contract? mxcTokenContract;
  Contract? zkCenterContract;

  String zkCenterName2 = '';

  bool connected = false;

  String selectedAccount = '';
  String lastTransaction = '';

  final String l1StakingName = 'staking';
  final String mxcTokenName = 'taiko_token';
  final String zkCenterName = 'zkcenter';

  final ethers = js.context['ethers']; // Get web global object (window.ethers)

  BigInt epochDuration = BigInt.from(0);
  BigInt minDeposit = BigInt.from(0);
  BigInt withDrawLockEpoch = BigInt.from(0);

  double adminFeeRate = 0;
  double commissionRate = 0;

  bool isEtherConnnected() {
    if (ethereum == null) {
      return false;
    } else {
      return ethereum!.isConnected();
    }
  }

  bool isEtherReady() {
    return (ethereum != null);
  }

  void disconnect() {
    connected = false;
    chainId = 0;
    accountList = [];
    taikoL1Address = '';
    l1StakingAddress = '';
    mxcTokenAddress = '';
    selectedAccount = '';

    taikoL1Contract = null;
    l1StakingContract = null;
    mxcTokenContract = null;
    zkCenterContract = null;
    web3 = null;
  }

  int hexStringToInt(String aStr) {
    return int.parse(aStr.replaceFirst('0x', ''), radix: 16);
  }

  Future<bool> connect() async {
    try {
      disconnect();

      if (ethers != null) {
        ethersVersion = ethers['version'];
        debugPrint('ethersVersion=$ethersVersion');
      }

      if (ethereum != null) {
        web3 = BrowserProvider(ethereum!);
        chainId = hexStringToInt(await promiseToFuture(
            ethereum!.request(RequestParams(method: 'eth_chainId'))));
        selectedAccount = ethereum!.selectedAddress;
        final ethAccountList = await promiseToFuture(
            ethereum!.request(RequestParams(method: 'eth_requestAccounts')));
        accountList.clear();
        for (var acc in ethAccountList) {
          debugPrint('  acc: $acc');
          accountList.add(acc);
        }
        debugPrint('selectedAccount $selectedAccount');
        debugPrint('chainId $chainId');

        //
        if (_chainIdIsMainnet(chainId)) {
          taikoL1Address = appData.mainnetContractInfo.taikoL1Address;
        } else if (_chainIdIsTestnet(chainId)) {
          taikoL1Address = appData.testnetContractInfo.taikoL1Address;
        }
        debugPrint('taikoL1Address $taikoL1Address');
        if (isArbiturm()) {
          taikoL1Contract = Contract(taikoL1Address, l1StakingAbi, web3);
          l1StakingAddress = await resolveAddress(l1StakingName);
          mxcTokenAddress = await resolveAddress(mxcTokenName);
          zkCenterAddress = await resolveAddress(zkCenterName);
        }

        if ((isArbiturm()) &&
            (l1StakingAddress.isNotEmpty) &&
            (mxcTokenAddress.isNotEmpty)) {
          final signer = await promiseToFuture(web3!.getSigner());
          debugPrint('signer: ${signer.address}');

          l1StakingContract =
              (Contract(l1StakingAddress, l1StakingAbi, web3)).connect(signer);
          mxcTokenContract =
              (Contract(mxcTokenAddress, mxcTokenAbi, web3)).connect(signer);
          zkCenterContract =
              (Contract(zkCenterAddress, zkCenterAbi, web3)).connect(signer);
          zkCenterName2 =
              await promiseToFuture(callMethod(zkCenterContract!, 'name2', []));
          debugPrint('ZkCenter: $zkCenterName2');
        }
        await updateConstants();

        connected = true;
        return true;
      } else {
        lastError = 'ethereum is null.';
        debugPrint('Error: $lastError');
        return false;
      }
    } catch (aError) {
      debugPrint('connect error. $aError');
      return true;
    }
  }

  // Update Contract constants
  Future<void> updateConstants() async {
    try {
      if (isContractReady()) {
        final epochDurationResp = await promiseToFuture(
            callMethod(l1StakingContract!, 'EPOCH_DURATION', []));
        epochDuration =
            BigInt.tryParse(epochDurationResp.toString()) ?? BigInt.from(0);

        final minDepositResp = await promiseToFuture(
            callMethod(l1StakingContract!, 'MIN_DEPOSIT', []));
        minDeposit =
            BigInt.tryParse(minDepositResp.toString()) ?? BigInt.from(0);

        final withDrawLockEpochResp = await promiseToFuture(
            callMethod(l1StakingContract!, 'WITHDRAWAL_LOCK_EPOCH', []));
        withDrawLockEpoch =
            BigInt.tryParse(withDrawLockEpochResp.toString()) ?? BigInt.from(0);

        debugPrint(
            'epochDuration=$epochDuration, minDeposit=$minDeposit, withDrawLockEpoch=$withDrawLockEpoch');

        //
        final adminFreeResp = await promiseToFuture(
            callMethod(zkCenterContract!, 'adminFee', []));
        final rawAdminFee =
            BigInt.tryParse(adminFreeResp.toString()) ?? BigInt.from(0);
        final commissionRateResp = await promiseToFuture(
            callMethod(zkCenterContract!, 'commissionRate', []));
        final rawCommissionRate =
            BigInt.tryParse(commissionRateResp.toString()) ?? BigInt.from(0);
        adminFeeRate = rawAdminFee.toDouble() / 10000;
        commissionRate = rawCommissionRate.toDouble() / 10000;
        debugPrint(
            'adminFeeRate=$adminFeeRate, commissionRate=$commissionRate');
      }
    } catch (aError) {
      debugPrint('updateConstants error. $aError');
    }
  }

  String epochToString(BigInt aEpoch) {
    if (aEpoch == BigInt.zero) {
      return '';
    } else {
      final dateFormat = DateFormat('yyyy-MMM-dd');
      final startTimestamp = (aEpoch * epochDuration).toInt();
      final endTimestamp = startTimestamp + epochDuration.toInt() - 1;
      final start = DateTime.fromMillisecondsSinceEpoch(startTimestamp * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(endTimestamp * 1000);
      return '${dateFormat.format(start.toUtc())} to ${dateFormat.format(end.toUtc())} UTC';
    }
  }

  Future<bool> isSignerChanged() async {
    try {
      if (ethereum != null) {
        final acc = ethereum!.selectedAddress;
        if (acc != selectedAccount) {
          return true;
        }
      } else if (selectedAccount.isNotEmpty) {
        return true;
      }
      return false;
    } catch (aError) {
      debugPrint('isSignerChanged error. $aError');
      return true;
    }
  }

  // Resolve Contract Address
  Future<String> resolveAddress(String aName) async {
    try {
      if ((ethers != null) && (taikoL1Contract != null)) {
        final encodedName =
            ethers.callMethod('encodeBytes32String', [aName]) as String;
        final contractResp = await promiseToFuture<String>(
            callMethod(taikoL1Contract!, 'resolve', [encodedName, false]));
        return contractResp;
      }
      return '';
    } catch (aError) {
      debugPrint('resolveAddress error. $aError');
      return '';
    }
  }

  // Get staking pool info
  Future<StakingPoolInfo?> getStakingPoolInfo() async {
    try {
      if ((connected) && (isContractReady())) {
        final stateResp = await promiseToFuture(
            callMethod(l1StakingContract!, 'stakingState', []));
        final totalBalance = BigInt.parse(stateResp[0].toString());
        final totalReward = BigInt.parse(stateResp[1].toString());
        final lastDeposit = BigInt.parse(stateResp[2].toString());
        final rewardBeginEpoch = BigInt.parse(stateResp[3].toString());

        final contractResp = await promiseToFuture(
            callMethod(l1StakingContract!, 'getCurrentEpoch', []));
        final currentEpoch = BigInt.parse(contractResp.toString());

        return StakingPoolInfo(
          totalAmount: totalBalance,
          rewardBalance: totalReward,
          lastDepositRewardTime:
              DateTime.fromMillisecondsSinceEpoch(lastDeposit.toInt() * 1000),
          rewardBeginEpoch: rewardBeginEpoch,
          currentEpoch: currentEpoch,
        );
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('getStakingState error. $aError');
      return null;
    }
  }

  // Get Balanaces
  Future<(BigInt, BigInt)> getBalances() async {
    try {
      if ((connected) && (ethereum != null) && (isContractReady())) {
        final resp = await promiseToFuture(ethereum!.request(RequestParams(
            method: 'eth_getBalance', params: [selectedAccount, 'latest'])));
        final ethBalance = BigInt.parse(resp.toString());

        final contractResp = await promiseToFuture(
            callMethod(mxcTokenContract!, 'balanceOf', [selectedAccount]));
        final mxcBalance = BigInt.parse(contractResp.toString());

        return (ethBalance, mxcBalance);
      } else {
        return (BigInt.from(0), BigInt.from(0));
      }
    } catch (aError) {
      debugPrint('getBalances error. $aError');
      return (BigInt.from(0), BigInt.from(0));
    }
  }

  // Get current block number
  Future<BigInt> getBlockNumber() async {
    try {
      if ((connected) && (ethereum != null)) {
        return BigInt.tryParse(await promiseToFuture(
                ethereum!.request(RequestParams(method: 'eth_blockNumber')))) ??
            BigInt.from(0);
      } else {
        return BigInt.from(0);
      }
    } catch (aError) {
      debugPrint('getBlockNumber error. $aError');
      return BigInt.from(0);
    }
  }

  // MxcToken.approve
  Future<(bool, String)> approve(double aAmount) async {
    if ((connected) && (isContractReady())) {
      try {
        final stakeAmountWei = mxcToWei(aAmount);
        final stakeAmount = '0x${stakeAmountWei.toRadixString(16)}';

        // approve
        final txnHash = await _sendAndWait(
            mxcTokenContract!, 'approve', [l1StakingAddress, stakeAmount]);

        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(mxcTokenContract!, aError.toString());
        lastError = 'approve failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.miningGroupGetId
  Future<BigInt?> miningGroupGetId() async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'miningGroupGetId', []));
        debugPrint('miningGroupGetId resp: $resp');
        return BigInt.parse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('miningGroupGetId error. $aError');
      return null;
    }
  }

  // ZkCenter.miningGroupGetTotal
  Future<BigInt?> miningGroupGetTotal() async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'miningGroupGetTotal', []));
        debugPrint('miningGroupGetTotal resp: $resp');
        return BigInt.parse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('miningGroupGetTotal error. $aError');
      return null;
    }
  }

  // ZkCenter.miningGroupGetIdByIndex
  Future<BigInt?> miningGroupGetIdByIndex(BigInt aIdx) async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final idx = '0x${aIdx.toRadixString(16)}';
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'miningGroupGetIdByIndex', [idx]));
        debugPrint('miningGroupGetIdByIndex resp: $resp');
        return BigInt.parse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('miningGroupGetIdByIndex error. $aError');
      return null;
    }
  }

  // ZkCenter.miningGroupGetLeader
  Future<String?> miningGroupGetLeader(BigInt aGroupId) async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final groupId = '0x${aGroupId.toRadixString(16)}';
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'miningGroupGetLeader', [groupId]));
        debugPrint('miningGroupGetLeader resp: $resp');
        return resp.toString();
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('miningGroupGetLeader error. $aError');
      return null;
    }
  }

  // ZkCenter.miningGroupGetMemberCount
  Future<BigInt?> miningGroupGetMemberCount(BigInt aGroupId) async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final groupId = '0x${aGroupId.toRadixString(16)}';
        final resp = await promiseToFuture(callMethod(
            zkCenterContract!, 'miningGroupGetMemberCount', [groupId]));
        debugPrint('miningGroupGetMemberCount resp: $resp');
        return BigInt.parse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('miningGroupGetMemberCount error. $aError');
      return null;
    }
  }

  // ZkCenter.stakeGetStatus
  Future<UserStakeStatus?> stakeGetStatus() async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final respGetStatus = await promiseToFuture(
            callMethod(zkCenterContract!, 'stakeGetStatus', []));
        debugPrint('stakingUserState resp: $respGetStatus');
        final stakingGroup = BigInt.parse(respGetStatus[0].toString());
        final stakedAmount = BigInt.parse(respGetStatus[1].toString());
        final lastClaimedEpoch = BigInt.parse(respGetStatus[2].toString());
        final withdrawalRequestEpoch =
            BigInt.parse(respGetStatus[3].toString());
        return UserStakeStatus(
          stakingGroup: stakingGroup,
          stakedAmount: stakedAmount,
          lastClaimedEpoch: lastClaimedEpoch,
          withdrawalRequestEpoch: withdrawalRequestEpoch,
        );
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('getStakingUserState error. $aError');
      return null;
    }
  }

  // ZkCenter.stakeGetGrossReward
  Future<BigInt?> stakeGetGrossReward() async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'stakeGetGrossReward', []));
        debugPrint('stakeGetGrossReward resp: $resp');
        return BigInt.tryParse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('stakeGetGrossReward error. $aError');
      return null;
    }
  }

  // ZkCenter.stakeGetCommission
  Future<BigInt?> stakeGetCommission() async {
    try {
      if ((connected) && (isContractReady()) && (selectedAccount.isNotEmpty)) {
        final resp = await promiseToFuture(
            callMethod(zkCenterContract!, 'stakeGetCommission', []));
        debugPrint('stakeGetCommission resp: $resp');
        return BigInt.tryParse(resp.toString());
      } else {
        return null;
      }
    } catch (aError) {
      debugPrint('stakeGetCommission error. $aError');
      return null;
    }
  }

  // ZkCenter.miningGroupCreate
  Future<(bool, String)> creatGroup() async {
    if ((connected) && (isContractReady())) {
      try {
        // miningGroupCreate()
        final txnHash =
            await _sendAndWait(zkCenterContract!, 'miningGroupCreate', []);
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'creatGroup failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeDeposit
  Future<(bool, String)> stakeDeposit(double aAmount) async {
    if ((connected) && (isContractReady())) {
      try {
        final stakeAmountWei = mxcToWei(aAmount);
        final stakeAmount = '0x${stakeAmountWei.toRadixString(16)}';

        // do stake
        final txnHash = await _sendAndWait(
            zkCenterContract!, 'stakeDeposit', [stakeAmount]);

        // final stakeTxn = await promiseToFuture(callMethod(
        //     l1StakingContract2, 'stake', [
        //   selectedAccount,
        //   stakeAmount
        // ])); // ethers.ContractTransactionResponse
        // final stakeRecp = await promiseToFuture(
        //     stakeTxn.wait()); // ethers.ContractTransactionReceipt | null
        // debugPrint('stake done. txn=${stakeRecp.hash}');
        // final txnHash = stakeRecp.hash == null ? '' : stakeRecp.hash as String;
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeDeposit failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeToGroup
  Future<(bool, String)> stakeToGroup(BigInt aGroupId, double aAmount) async {
    if ((connected) && (isContractReady())) {
      try {
        final stakeAmountWei = mxcToWei(aAmount);
        final stakeAmount = '0x${stakeAmountWei.toRadixString(16)}';
        final groupId = '0x${aGroupId.toRadixString(16)}';
        final txnHash = await _sendAndWait(
            zkCenterContract!, 'stakeToGroup', [groupId, stakeAmount]);
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeDeposit failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeClaimReward
  Future<(bool, String)> stakeClaimReward() async {
    if ((connected) && (isContractReady())) {
      try {
        debugPrint('ZkCenter.stakeClaimReward');
        final txnHash =
            await _sendAndWait(zkCenterContract!, 'stakeClaimReward', []);
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeClaimReward failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeClaimCommission
  Future<(bool, String)> stakeClaimCommission() async {
    if ((connected) && (isContractReady())) {
      try {
        debugPrint('ZkCenter.stakeClaimCommission');
        final txnHash =
            await _sendAndWait(zkCenterContract!, 'stakeClaimCommission', []);
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeClaimCommission failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeRequestWithdraw
  Future<(bool, String)> stakeRequestWithdraw(bool aCancel) async {
    if ((connected) && (isContractReady())) {
      try {
        // final signer = await promiseToFuture(web3!.getSigner());
        // final l1StakingContract2 = l1StakingContract!.connect(signer);

        // do withdraw requst
        final txnHash = await _sendAndWait(
            zkCenterContract!, 'stakeRequestWithdraw', [aCancel]);

        // final stakeTxn = await promiseToFuture(callMethod(
        //     l1StakingContract2,
        //     'stakingRequestWithdrawal',
        //     [aCancel])); // ethers.ContractTransactionResponse
        // final stakeRecp = await promiseToFuture(
        //     stakeTxn.wait()); // ethers.ContractTransactionReceipt | null
        // debugPrint('requstWithdraw done. txn=${stakeRecp.hash}');
        // final txnHash = stakeRecp.hash == null ? '' : stakeRecp.hash as String;
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeRequestWithdraw failed. ${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // ZkCenter.stakeWithdraw
  Future<(bool, String)> stakeWithdraw() async {
    if ((connected) && (isContractReady())) {
      try {
        // final signer = await promiseToFuture(web3!.getSigner());
        // final l1StakingContract2 = l1StakingContract!.connect(signer);

        // do withdraw
        final txnHash =
            await _sendAndWait(zkCenterContract!, 'stakeWithdraw', []);

        // final stakeTxn = await promiseToFuture(callMethod(l1StakingContract2,
        //     'stakingWithdrawal', [])); // ethers.ContractTransactionResponse
        // final stakeRecp = await promiseToFuture(
        //     stakeTxn.wait()); // ethers.ContractTransactionReceipt | null
        // debugPrint('doWithdraw done. txn=${stakeRecp.hash}');
        // final txnHash = stakeRecp.hash == null ? '' : stakeRecp.hash as String;
        return (true, txnHash);
      } catch (aError) {
        final decodedReason =
            _decodeRevertReason(zkCenterContract!, aError.toString());
        lastError = 'stakeWithdraw failed.\n${aError.toString()}';
        if (decodedReason.isNotEmpty) {
          lastError = '$lastError\nRevert reason: $decodedReason';
        }
        debugPrint(lastError);
        return (false, '');
      }
    }
    return (false, '');
  }

  // Try decode contract custom revert reason
  String _decodeRevertReason(Contract aContract, String aError) {
    if (aError.contains('execution reverted') &&
        aError.contains('reason=null')) {
      final startIdx = aError.indexOf(RegExp(r'data="[^"]*"'));
      final endIdx = aError.indexOf('",', startIdx);
      if ((startIdx >= 0) && (endIdx >= 0) && (endIdx > startIdx)) {
        final signature = aError.substring(startIdx + 6, endIdx);
        if (hasProperty(aContract, 'interface')) {
          final interface = getProperty(aContract, 'interface');
          try {
            final contractError =
                callMethod(interface, 'getError', [signature]);
            if (contractError.name != null) {
              return contractError.name;
            }
          } catch (_) {
            return '';
          }
        }
      }
      return '';
    } else {
      return '';
    }
  }

  // Send a transaction and wait
  Future<String> _sendAndWait(
    Object aContract,
    String aMethod,
    List<Object?> aArgs,
  ) async {
    final contractFunc = await callMethod(aContract, 'getFunction', [aMethod]);
    final txnResp = await promiseToFuture(callMethod(
        contractFunc!, 'send', aArgs)); // ethers.ContractTransactionResponse
    final txnReceipt = await promiseToFuture(callMethod(
        txnResp!, 'wait', [])); // ethers.ContractTransactionReceipt | null

    String txnHash = '';
    if (txnReceipt != null) {
      txnHash = getProperty(txnReceipt!, 'hash') as String;
    }
    print('$aMethod done. txn=$txnHash');

    return txnHash;
  }

  // Checking change of chain
  Future<bool> isChainChanged() async {
    try {
      if (ethereum != null) {
        final id = hexStringToInt(await promiseToFuture(
            ethereum!.request(RequestParams(method: 'eth_chainId'))));
        return (id != chainId);
      } else {
        return false;
      }
    } catch (aError) {
      debugPrint('isChainChanged error. $aError');
      return false;
    }
  }

  // Chains
  String chainName() {
    return MoonchainUtils.chainIdToName(chainId);
  }

  bool isTestnet() {
    return _chainIdIsTestnet(chainId);
  }

  bool isMainnet() {
    return _chainIdIsMainnet(chainId);
  }

  bool isArbiturm() {
    return _chainIdIsArbiturm(chainId);
  }

  bool isContractReady() {
    return ((taikoL1Contract != null) &&
        (l1StakingContract != null) &&
        (mxcTokenContract != null));
  }

  String chainExplorerUrl() {
    if (_chainIdIsTestnet(chainId)) {
      return 'https://sepolia.arbiscan.io/';
    } else if (_chainIdIsMainnet(chainId)) {
      return 'https://arbiscan.io/';
    } else {
      return '';
    }
  }

  // Helper
  double weiToMxc(BigInt aValue) {
    if (ethers != null) {
      final s = ethers.callMethod('formatEther', [aValue.toString()]) as String;
      return double.tryParse(s) ?? 0;
    } else {
      // Fallback to using dart
      return (aValue / BigInt.from(1000000000000000000)).toDouble();
    }
  }

  BigInt mxcToWei(double? aValue) {
    if (aValue == null) {
      return BigInt.from(0);
    } else {
      if (js.context['parseEtherWrapper'] != null) {
        final b = js.context
            .callMethod('parseEtherWrapper', [aValue.toString()]) as String;
        return BigInt.tryParse(b) ?? BigInt.from(0);
      } else {
        // Fallback to using dart
        return BigInt.from(aValue * 1000000000) * BigInt.from(1000000000);
      }
    }
  }

  static String trimPidHashForDisplaying(BigInt aPidZkevmHash) {
    String strPidHash = '0x${aPidZkevmHash.toRadixString(16)}';
    if (strPidHash.length > 32) {
      strPidHash = '${strPidHash.substring(0, 30)}...';
    }
    return strPidHash;
  }

  bool _chainIdIsTestnet(int aId) {
    return (aId == 421614);
  }

  bool _chainIdIsMainnet(int aId) {
    return (aId == 42161);
  }

  bool _chainIdIsArbiturm(int aId) {
    return ((aId == 421614) || (aId == 42161));
  }
}
