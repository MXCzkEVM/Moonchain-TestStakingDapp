part of 'claim_cubit.dart';

@JsonSerializable()
class ClaimState extends Equatable {
  const ClaimState({
    required this.lastUpdate,
    required this.waiting,
    required this.waitingMessage,
    required this.selectedAccount,
    required this.totalBalanceMxc,
    required this.ethBalance,
    required this.mxcBalance,
    required this.transactionInProgress,
    required this.transactionDone,
    required this.transactionResult,
    required this.currentEpoch,
    required this.rewardBeginEpoch,
    required this.lastClaimedEpoch,
    required this.stakingBalancesMxc,
    required this.stakingBalances,
    required this.grossReward,
    required this.grossRewardMxc,
    required this.netRewardMxc,
  });

  // properties
  final DateTime lastUpdate;
  final bool waiting;
  final String waitingMessage;
  final String selectedAccount;
  final String totalBalanceMxc;

  final String ethBalance;
  final String mxcBalance;

  final bool transactionInProgress;
  final bool transactionDone;
  final String transactionResult;

  final String currentEpoch;
  final String rewardBeginEpoch;
  final String lastClaimedEpoch;
  final String stakingBalancesMxc;
  final BigInt stakingBalances;
  final BigInt grossReward;
  final String grossRewardMxc;
  final String netRewardMxc;

  //
  static final initial = ClaimState(
    lastUpdate: DateTime.now(),
    waiting: false,
    waitingMessage: '...',
    selectedAccount: '',
    totalBalanceMxc: '',
    ethBalance: '',
    mxcBalance: '',
    transactionInProgress: false,
    transactionDone: false,
    transactionResult: 'UNKNOWN',
    currentEpoch: '',
    rewardBeginEpoch: '',
    lastClaimedEpoch: '',
    stakingBalancesMxc: '',
    stakingBalances: BigInt.from(0),
    grossReward: BigInt.from(0),
    grossRewardMxc: '',
    netRewardMxc: '',
  );

  //
  ClaimState copyWith({
    String? selectedAccount,
    bool? waiting,
    String? waitingMessage,
    String? totalBalanceMxc,
    String? ethBalance,
    String? mxcBalance,
    bool? transactionInProgress,
    bool? transactionDone,
    String? transactionResult,
    String? currentEpoch,
    String? rewardBeginEpoch,
    String? lastClaimedEpoch,
    String? stakingBalancesMxc,
    BigInt? stakingBalances,
    BigInt? grossReward,
    String? grossRewardMxc,
    String? netRewardMxc,
  }) {
    return ClaimState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      waitingMessage: waitingMessage ?? this.waitingMessage,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      totalBalanceMxc: totalBalanceMxc ?? this.totalBalanceMxc,
      ethBalance: ethBalance ?? this.ethBalance,
      mxcBalance: mxcBalance ?? this.mxcBalance,
      transactionInProgress:
          transactionInProgress ?? this.transactionInProgress,
      transactionDone: transactionDone ?? this.transactionDone,
      transactionResult: transactionResult ?? this.transactionResult,
      currentEpoch: currentEpoch ?? this.currentEpoch,
      rewardBeginEpoch: rewardBeginEpoch ?? this.rewardBeginEpoch,
      lastClaimedEpoch: lastClaimedEpoch ?? this.lastClaimedEpoch,
      stakingBalancesMxc: stakingBalancesMxc ?? this.stakingBalancesMxc,
      stakingBalances: stakingBalances ?? this.stakingBalances,
      grossReward: grossReward ?? this.grossReward,
      grossRewardMxc: grossRewardMxc ?? this.grossRewardMxc,
      netRewardMxc: netRewardMxc ?? this.netRewardMxc,
    );
  }

  //
  @override
  List<Object> get props => [lastUpdate];

  factory ClaimState.fromJson(Map<String, dynamic> json) =>
      _$ClaimStateFromJson(json);

  Map<String, dynamic> toJson() => _$ClaimStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
