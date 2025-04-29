part of 'home_cubit.dart';

@JsonSerializable()
class HomeState extends Equatable {
  const HomeState({
    required this.lastUpdate,
    required this.waiting,
    required this.isNetworkConnected,
    required this.chainId,
    required this.chainName,
    required this.isTestnet,
    required this.isTargetChain,
    required this.blockNumber,
    required this.gasPrice,
    required this.accountList,
    required this.selectedAccount,
    required this.ethersVersion,
    required this.taikoL1Address,
    required this.l1StakingAddress,
    required this.mxcTokenAddress,
    required this.zkCenterAddress,
    required this.zkCenterName2,
    required this.stakingPoolInfo,
    required this.userStakeStatus,
    required this.ethBalance,
    required this.mxcBalance,
    required this.grossReward,
    required this.grossRewardMxc,
    required this.minerCount,
  });

  // properties
  final DateTime lastUpdate;
  final bool waiting;
  final bool isNetworkConnected;
  final int chainId;
  final String chainName;
  final bool isTestnet;
  final bool isTargetChain;
  final BigInt blockNumber;
  final BigInt gasPrice;
  final List<String> accountList;
  final String selectedAccount;
  final String ethersVersion;

  final String taikoL1Address;
  final String l1StakingAddress;
  final String mxcTokenAddress;
  final String zkCenterAddress;

  final String zkCenterName2;

  final UiStakingPoolInfo stakingPoolInfo;
  final UiUserStakeStatus userStakeStatus;

  final String ethBalance;
  final String mxcBalance;

  final BigInt grossReward;
  final String grossRewardMxc;

  final int minerCount;

  //
  static final initial = HomeState(
    lastUpdate: DateTime.now(),
    waiting: false,
    isNetworkConnected: false,
    chainId: 0,
    chainName: 'Unsupported',
    isTestnet: false,
    isTargetChain: false,
    blockNumber: BigInt.from(0),
    gasPrice: BigInt.from(0),
    accountList: const [],
    selectedAccount: '',
    ethersVersion: '',
    taikoL1Address: '',
    l1StakingAddress: '',
    mxcTokenAddress: '',
    zkCenterAddress: '',
    zkCenterName2: '',
    stakingPoolInfo: UiStakingPoolInfo.initial,
    userStakeStatus: UiUserStakeStatus.initial,
    ethBalance: '',
    mxcBalance: '',
    grossReward: BigInt.zero,
    grossRewardMxc: '',
    minerCount: 0,
  );

  //
  HomeState copyWith({
    bool? waiting,
    bool? isNetworkConnected,
    int? chainId,
    String? chainName,
    bool? isTestnet,
    bool? isTargetChain,
    BigInt? blockNumber,
    BigInt? gasPrice,
    List<String>? accountList,
    String? selectedAccount,
    String? ethersVersion,
    String? taikoL1Address,
    String? l1StakingAddress,
    String? mxcTokenAddress,
    String? zkCenterAddress,
    String? zkCenterName2,
    UiStakingPoolInfo? stakingPoolInfo,
    UiUserStakeStatus? userStakeStatus,
    String? ethBalance,
    String? mxcBalance,
    BigInt? grossReward,
    String? grossRewardMxc,
    int? minerCount,
  }) {
    return HomeState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      chainId: chainId ?? this.chainId,
      chainName: chainName ?? this.chainName,
      isTestnet: isTestnet ?? this.isTestnet,
      isTargetChain: isTargetChain ?? this.isTargetChain,
      blockNumber: blockNumber ?? this.blockNumber,
      gasPrice: gasPrice ?? this.gasPrice,
      accountList: accountList ?? this.accountList,
      ethersVersion: ethersVersion ?? this.ethersVersion,
      taikoL1Address: taikoL1Address ?? this.taikoL1Address,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      l1StakingAddress: l1StakingAddress ?? this.l1StakingAddress,
      mxcTokenAddress: mxcTokenAddress ?? this.mxcTokenAddress,
      zkCenterAddress: zkCenterAddress ?? this.zkCenterAddress,
      zkCenterName2: zkCenterName2 ?? this.zkCenterName2,
      stakingPoolInfo: stakingPoolInfo ?? this.stakingPoolInfo,
      userStakeStatus: userStakeStatus ?? this.userStakeStatus,
      ethBalance: ethBalance ?? this.ethBalance,
      mxcBalance: mxcBalance ?? this.mxcBalance,
      grossReward: grossReward ?? this.grossReward,
      grossRewardMxc: grossRewardMxc ?? this.grossRewardMxc,
      minerCount: minerCount ?? this.minerCount,
    );
  }

  //
  @override
  List<Object> get props => [lastUpdate];

  factory HomeState.fromJson(Map<String, dynamic> json) =>
      _$HomeStateFromJson(json);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
