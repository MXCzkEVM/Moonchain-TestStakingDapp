import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../stake.dart';

class StakePage extends StatelessWidget {
  const StakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StakeCubit(
        tickerCheck: const Ticker(name: 'StakeCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
      ),
      // child: const MediaWrapper(child: StakePageView()),
      child: StakePageView(),
    );
  }
}

class StakePageView extends StatelessWidget {
  const StakePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stake'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.home), onPressed: routes.backToHome),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<StakeCubit, StakeState>(
                buildWhen: (prev, current) =>
                    prev.waiting != current.waiting ||
                    prev.transactionDone != current.transactionDone,
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
    return BlocBuilder<StakeCubit, StakeState>(builder: (context, state) {
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
    return BlocBuilder<StakeCubit, StakeState>(builder: (context, state) {
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
    return BlocBuilder<StakeCubit, StakeState>(builder: (context, state) {
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
        child: BlocBuilder<StakeCubit, StakeState>(builder: (context, state) {
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
          BlocBuilder<StakeCubit, StakeState>(
              buildWhen: (prev, current) =>
                  prev.minDepositMxc != current.minDepositMxc,
              builder: (context, state) {
                return Text(
                  'Minium amount: ${state.minDepositMxc} MXC',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                );
              }),
          const SizedBox(height: 10),
          BlocBuilder<StakeCubit, StakeState>(
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
                            .read<StakeCubit>()
                            .setStakeAmount(amount.toString());
                      },
                    ),
                    OutlinedButton(
                      child: const Text('Min'),
                      onPressed: () {
                        context
                            .read<StakeCubit>()
                            .setStakeAmount(state.minDepositMxc);
                      },
                    ),
                  ],
                );
              }),
          BlocBuilder<StakeCubit, StakeState>(
              buildWhen: (previous, current) =>
                  previous.stakeAmount != current.stakeAmount,
              builder: (context, state) {
                return LabeledTextField(
                    label: "Amount",
                    initialValue: state.stakeAmount,
                    onSubmitted: (aValue) {
                      context.read<StakeCubit>().setStakeAmount(aValue);
                    });
              }),
          const SizedBox(height: 10),
          OutlinedButton(
            child: const Text('Stake'),
            onPressed: () {
              final StakeCubit cubit = context.read<StakeCubit>();
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
        child: BlocBuilder<StakeCubit, StakeState>(builder: (context, state) {
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
