part of 'create_group_cubit.dart';

@JsonSerializable()
class CreateGroupState extends Equatable {
  const CreateGroupState({
    required this.lastUpdate,
    required this.waiting,
    required this.waitingMessage,
    required this.selectedAccount,
    required this.ethBalance,
    required this.mxcBalance,
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

  final String ethBalance;
  final String mxcBalance;

  final bool transactionInProgress;
  final bool transactionDone;
  final String transactionResult;

  final BigInt minDeposit;
  final String minDepositMxc;

  //
  static final initial = CreateGroupState(
    lastUpdate: DateTime.now(),
    waiting: false,
    waitingMessage: '...',
    selectedAccount: '',
    ethBalance: '',
    mxcBalance: '',
    transactionInProgress: false,
    transactionDone: false,
    transactionResult: "UNKNOWN",
    minDeposit: BigInt.zero,
    minDepositMxc: '',
  );

  //
  CreateGroupState copyWith({
    String? selectedAccount,
    bool? waiting,
    String? waitingMessage,
    String? ethBalance,
    String? mxcBalance,
    bool? transactionInProgress,
    bool? transactionDone,
    String? transactionResult,
    BigInt? minDeposit,
    String? minDepositMxc,
  }) {
    return CreateGroupState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      waitingMessage: waitingMessage ?? this.waitingMessage,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      ethBalance: ethBalance ?? this.ethBalance,
      mxcBalance: mxcBalance ?? this.mxcBalance,
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

  factory CreateGroupState.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupStateFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGroupStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
