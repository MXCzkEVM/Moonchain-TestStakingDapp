part of 'miner_cubit.dart';

@JsonSerializable()
class MinerState extends Equatable {
  const MinerState({
    required this.lastUpdate,
    required this.waiting,
    required this.waitingMessage,
    required this.selectedAccount,
    required this.appToken,
    required this.minerCount,
    required this.minerList,
  });

  // properties
  final DateTime lastUpdate;
  final bool waiting;
  final String waitingMessage;
  final String selectedAccount;

  final String appToken;

  final int minerCount;
  final List<UiMinerInfo> minerList;

  //
  static final initial = MinerState(
    lastUpdate: DateTime.now(),
    waiting: false,
    waitingMessage: '...',
    selectedAccount: '',
    appToken: '',
    minerCount: 0,
    minerList: [],
  );

  //
  MinerState copyWith({
    String? selectedAccount,
    bool? waiting,
    String? waitingMessage,
    String? appToken,
    int? minerCount,
    List<UiMinerInfo>? minerList,
  }) {
    return MinerState(
      lastUpdate: DateTime.now(),
      waiting: waiting ?? this.waiting,
      waitingMessage: waitingMessage ?? this.waitingMessage,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      appToken: appToken ?? this.appToken,
      minerCount: minerCount ?? this.minerCount,
      minerList: minerList ?? this.minerList,
    );
  }

  //
  @override
  List<Object> get props => [lastUpdate];

  factory MinerState.fromJson(Map<String, dynamic> json) =>
      _$MinerStateFromJson(json);

  Map<String, dynamic> toJson() => _$MinerStateToJson(this);

  String toJsonString() => jsonEncode(toJson());
}
