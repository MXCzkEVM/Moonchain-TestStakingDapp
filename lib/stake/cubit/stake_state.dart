part of 'stake_cubit.dart';

@JsonSerializable()
class StakeState extends Equatable {
  const StakeState({
    required this.lastUpdate,
    required this.waiting,
    required this.waitingMessage,
    required this.selectedAccount,
    required this.totalBalanceMxc,
    required this.ethBalance,
    required this.mxcBalance,
    required this.stakeAmount,
    required this.transactionInProgress,
    required this.transactionDone,
    required this.transactionResult,
    required this.minDeposit,
    required this.minDepositMxc,
  });

  // properties
  final DateTime lastUpdate;
  final bool waiting;
  final String waitingMessage;
  final String selectedAccount;
  final String totalBalanceMxc;

  final String ethBalance;
  final String mxcBalance;

  final String stakeAmount;

  final bool transactionInProgress;
  final bool transactionDone;
  final String transactionResult;

  final BigInt minDeposit;
  final String minDepositMxc;

  //
  static final initial = StakeState(
    lastUpdate: DateTime.now(),
    waiting: false,
    waitingMessage: '...',
    selectedAccount: '',
    totalBalanceMxc: '',
    ethBalance: '',
    mxcBalance: '',
    stakeAmount: '',
    transactionInProgress: false,
    transactionDone: false,
    transactionResult: "UNKNOWN",
    minDeposit: BigInt.zero,
    minDepositMxc: '',
  );

  //
  StakeState copyWith({
    String? selectedAccount,
    bool? waiting,
    String? waitingMessage,
    String? totalBalanceMxc,
    String? ethBalance,
    String? mxcBalance,
    String? stakeAmount,
    bool? transactionInProgress,
    bool? transactionDone,
    String? transactionResult,
    BigInt? minDeposit,
    String? minDepositMxc,
  }) {
    return StakeState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      waitingMessage: waitingMessage ?? this.waitingMessage,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      totalBalanceMxc: totalBalanceMxc ?? this.totalBalanceMxc,
      ethBalance: ethBalance ?? this.ethBalance,
      mxcBalance: mxcBalance ?? this.mxcBalance,
      stakeAmount: stakeAmount ?? this.stakeAmount,
      transactionInProgress: transactionInProgress ?? this.transactionInProgress,
      transactionDone: transactionDone ?? this.transactionDone,
      transactionResult: transactionResult ?? this.transactionResult,
      minDeposit: minDeposit ?? this.minDeposit,
      minDepositMxc: minDepositMxc ?? this.minDepositMxc,
    );
  }

  //
  @override
  List<Object> get props => [lastUpdate];

  factory StakeState.fromJson(Map<String, dynamic> json) =>
      _$StakeStateFromJson(json);

  Map<String, dynamic> toJson() => _$StakeStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
