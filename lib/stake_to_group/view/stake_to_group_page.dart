import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../stake_to_group.dart';

class StakeToGroupPage extends StatelessWidget {
  const StakeToGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StakeToGroupCubit(
        tickerCheck:
            const Ticker(name: 'StakeToGroupCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
        localSettingRepos: context.read<LocalSettingRepos>(),
        proverServiceRepos: context.read<ProverServiceRepos>(),
      ),
      // child: const MediaWrapper(child: StakeToGroupPageView()),
      child: StakeToGroupPageView(),
    );
  }
}

class StakeToGroupPageView extends StatelessWidget {
  const StakeToGroupPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stake to Group'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.home), onPressed: routes.backToHome),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
                buildWhen: (prev, current) =>
                    prev.waiting != current.waiting ||
                    prev.transactionDone != current.transactionDone ||
                    prev.inGroup != current.inGroup,
                builder: (context, state) {
                  return state.transactionDone
                      ? const TransactionDoneBox()
                      : state.waiting
                          ? WaitingBox()
                          : ListView(children: [
                              HeaderInfoPanel(),
                              SizedBox(height: 10),
                              BalancePanel(),
                              SizedBox(height: 10),
                              state.inGroup ? InGroupBox() : GroupList(),
                              SizedBox(height: 10),
                              ActionPanel(),
                              SizedBox(height: 10),
                            ]);
                })),
      ),
    );
  }
}

class WaitingBox extends StatelessWidget {
  const WaitingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
        builder: (context, state) {
      return Column(
        children: [CircularProgressIndicator(), Text(state.waitingMessage)],
      );
    });
  }
}

class TransactionDoneBox extends StatelessWidget {
  const TransactionDoneBox({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
        builder: (context, state) {
      return Column(children: [
        const SizedBox(height: 10),
        SelectableText(state.transactionResult),
        const SizedBox(height: 10),
        ElevatedButton(
          child: const Text("Exit"),
          onPressed: () {
            routes.backToHome();
          },
        ),
      ]);
    });
  }
}

class HeaderInfoPanel extends StatelessWidget {
  const HeaderInfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
        builder: (context, state) {
      return Column(children: [
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Text(
              'Last updated: ${DateFormat('yyyy-MMM-dd HH:mm:ss').format(state.lastUpdate.toUtc())} UTC',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Wallet: ${state.selectedAccount}',
              style: TextStyle(fontSize: 11, fontFamily: 'RobotoMono'),
            ),
          ],
        ),
      ]);
    });
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Info',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
            builder: (context, state) {
          return Column(children: [
            LabeledText(
              label: 'Staked Amount',
              value: '${state.totalBalanceMxc} MXC',
            ),
          ]);
        }),
      ),
    );
  }
}

class ActionPanel extends StatelessWidget {
  const ActionPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Actions',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(children: [
          const Row(children: [SizedBox(height: 10)]),
          BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
              buildWhen: (prev, current) =>
                  prev.minDepositMxc != current.minDepositMxc,
              builder: (context, state) {
                return Text(
                  'Minium amount: ${state.minDepositMxc} MXC',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                );
              }),
          const SizedBox(height: 10),
          BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
              buildWhen: (prev, current) =>
                  prev.minDeposit != current.minDeposit ||
                  prev.stakeAmount != current.stakeAmount,
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(child: SizedBox()),
                    OutlinedButton(
                      child: const Text('+1m'),
                      onPressed: () {
                        final amount =
                            (double.tryParse(state.stakeAmount) ?? 0.0) +
                                1000000.0;
                        context
                            .read<StakeToGroupCubit>()
                            .setStakeAmount(amount.toString());
                      },
                    ),
                    OutlinedButton(
                      child: const Text('Min'),
                      onPressed: () {
                        context
                            .read<StakeToGroupCubit>()
                            .setStakeAmount(state.minDepositMxc);
                      },
                    ),
                  ],
                );
              }),
          BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
              buildWhen: (previous, current) =>
                  previous.stakeAmount != current.stakeAmount,
              builder: (context, state) {
                return LabeledTextField(
                    label: "Amount",
                    initialValue: state.stakeAmount,
                    onSubmitted: (aValue) {
                      context.read<StakeToGroupCubit>().setStakeAmount(aValue);
                    });
              }),
          const SizedBox(height: 10),
          OutlinedButton(
            child: const Text('Stake'),
            onPressed: () {
              final StakeToGroupCubit cubit = context.read<StakeToGroupCubit>();
              cubit.startStaking().then((aResult) {
                if ((aResult == false) && (context.mounted)) {
                  MessageBox.show(context, "ERROR",
                      "Cannot start the transaction.\n${cubit.lastError}", 400);
                }
              });
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            child: const Text('Exit'),
            onPressed: () {
              routes.backToHome();
            },
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class BalancePanel extends StatelessWidget {
  const BalancePanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'My Balance',
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        child: BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
            builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                    state.ethBalance,
                    style: TextStyle(fontSize: 18, fontFamily: 'RobotoMono'),
                    textAlign: TextAlign.end,
                  )),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'ETH',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: Text(
                    state.mxcBalance,
                    style: TextStyle(fontSize: 18, fontFamily: 'RobotoMono'),
                    textAlign: TextAlign.end,
                  )),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'MXC',
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  GroupList({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text('Mining Groups',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold))),
      ]),
      Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
            builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    "Total ${state.groupList.length}",
                    style: const TextStyle(
                        fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary)),
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(5),
                          itemCount: state.groupList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GroupInfoBox(
                              item: state.groupList[index],
                              selected:
                                  state.selectedGroup == state.groupList[index],
                              onTap: () {
                                final idx = state.selectedGroup ==
                                        state.groupList[index]
                                    ? -1
                                    : index;
                                context
                                    .read<StakeToGroupCubit>()
                                    .selectGroup(idx);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    ]);
  }
}

class InGroupBox extends StatelessWidget {
  const InGroupBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text('Mining Group',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold))),
      ]),
      Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: BlocBuilder<StakeToGroupCubit, StakeToGroupState>(
            builder: (context, state) {
          return Column(children: [
            Row(
              children: [
                Expanded(
                  child: GroupInfoBox(
                    item: state.selectedGroup,
                    selected: true,
                  ),
                ),
              ],
            )
          ]);
        }),
      ),
    ]);
  }
}

class GroupInfoBox extends StatelessWidget {
  const GroupInfoBox(
      {super.key, required this.item, required this.selected, this.onTap});

  final UiGroupInfo item;
  final bool selected;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
          color: selected ? Theme.of(context).highlightColor : null,
        ),
        child: Column(children: [
          Text("GroupId ${item.strId}"),
          Text('Owner: ${item.owner}', style: const TextStyle(fontSize: 10)),
          Text('Member Count: ${item.memberCount}',
              style: const TextStyle(fontSize: 10)),
        ]),
      ),
    );
  }
}
