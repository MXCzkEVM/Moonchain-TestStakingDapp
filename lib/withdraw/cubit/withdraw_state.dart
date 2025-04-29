part of 'withdraw_cubit.dart';

@JsonSerializable()
class WithdrawState extends Equatable {
  const WithdrawState({
    required this.lastUpdate,
    required this.waiting,
    required this.waitingMessage,
    required this.selectedAccount,
    required this.ethBalance,
    required this.mxcBalance,
    required this.transactionInProgress,
    required this.transactionDone,
    required this.transactionResult,
    required this.currentEpoch,
    required this.stakingBalances,
    required this.stakingBalancesMxc,
    required this.withdrawalRequestEpoch,
    required this.strWithdrawalRequestEpoch,
    required this.withDrawLockEpoch,
    required this.isLocked,
    required this.grossReward,
    required this.grossRewardMxc,
  });

  // properties
  final DateTime lastUpdate;
  final bool waiting;
  final String waitingMessage;
  final String selectedAccount;

  final String ethBalance;
  final String mxcBalance;

  final bool transactionInProgress;
  final bool transactionDone;
  final String transactionResult;

  final String currentEpoch;
  final BigInt stakingBalances;
  final String stakingBalancesMxc;
  final BigInt withdrawalRequestEpoch;
  final String strWithdrawalRequestEpoch;
  final BigInt withDrawLockEpoch;
  final bool isLocked;
  final BigInt grossReward;
  final String grossRewardMxc;

  //
  static final initial = WithdrawState(
    lastUpdate: DateTime.now(),
    waiting: false,
    waitingMessage: '...',
    selectedAccount: '',
    ethBalance: '',
    mxcBalance: '',
    transactionInProgress: false,
    transactionDone: false,
    transactionResult: 'UNKNOWN',
    currentEpoch: '',
    stakingBalances: BigInt.from(0),
    stakingBalancesMxc: '',
    withdrawalRequestEpoch: BigInt.from(0),
    strWithdrawalRequestEpoch: '',
    withDrawLockEpoch: BigInt.from(0),
    isLocked: true,
    grossReward: BigInt.from(0),
    grossRewardMxc: '',
  );

  //
  WithdrawState copyWith({
    String? selectedAccount,
    bool? waiting,
    String? waitingMessage,
    String? ethBalance,
    String? mxcBalance,
    bool? transactionInProgress,
    bool? transactionDone,
    String? transactionResult,
    String? currentEpoch,
    BigInt? stakingBalances,
    String? stakingBalancesMxc,
    BigInt? withdrawalRequestEpoch,
    String? strWithdrawalRequestEpoch,
    BigInt? withDrawLockEpoch,
    bool? isLocked,
    BigInt? grossReward,
    String? grossRewardMxc,
  }) {
    return WithdrawState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      waitingMessage: waitingMessage ?? this.waitingMessage,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      ethBalance: ethBalance ?? this.ethBalance,
      mxcBalance: mxcBalance ?? this.mxcBalance,
      transactionInProgress:
          transactionInProgress ?? this.transactionInProgress,
      transactionDone: transactionDone ?? this.transactionDone,
      transactionResult: transactionResult ?? this.transactionResult,
      currentEpoch: currentEpoch ?? this.currentEpoch,
      stakingBalances: stakingBalances ?? this.stakingBalances,
      stakingBalancesMxc: stakingBalancesMxc ?? this.stakingBalancesMxc,
      withdrawalRequestEpoch:
          withdrawalRequestEpoch ?? this.withdrawalRequestEpoch,
      strWithdrawalRequestEpoch:
          strWithdrawalRequestEpoch ?? this.strWithdrawalRequestEpoch,
      withDrawLockEpoch: withDrawLockEpoch ?? this.withDrawLockEpoch,
      isLocked: isLocked ?? this.isLocked,
      grossReward: grossReward ?? this.grossReward,
      grossRewardMxc: grossRewardMxc ?? this.grossRewardMxc,
    );
  }

  //
  @override
  List<Object> get props => [lastUpdate];

  factory WithdrawState.fromJson(Map<String, dynamic> json) =>
      _$WithdrawStateFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
