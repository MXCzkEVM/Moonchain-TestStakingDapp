import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../commission.dart';

class CommissionPage extends StatelessWidget {
  const CommissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommissionCubit(
        tickerCheck: const Ticker(name: 'CommissionCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
      ),
      // child: const MediaWrapper(child: CommissionPageView()),
      child: CommissionPageView(),
    );
  }
}

class CommissionPageView extends StatelessWidget {
  const CommissionPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commission'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.home), onPressed: routes.backToHome),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<CommissionCubit, CommissionState>(
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
                              InfoPanel(),
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
    return BlocBuilder<CommissionCubit, CommissionState>(builder: (context, state) {
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
    return BlocBuilder<CommissionCubit, CommissionState>(builder: (context, state) {
      return Column(children: [
        const SizedBox(height: 10),
        SelectableText(state.transactionResult),
        const SizedBox(height: 10),
        ElevatedButton(
          child: const Text('Exit'),
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
    return BlocBuilder<CommissionCubit, CommissionState>(builder: (context, state) {
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
        child: BlocBuilder<CommissionCubit, CommissionState>(builder: (context, state) {
          return Column(children: [
            LabeledText(
              label: 'Staking Pool Total Amount',
              value: '${state.totalBalanceMxc} MXC',
            ),
            LabeledText(
              label: 'Current Epoch',
              value: state.currentEpoch,
            ),
            LabeledText(
              label: 'Staked Amount',
              value: '${state.stakingBalancesMxc} MXC',
            ),
            LabeledText(
              label: 'Last Claim (Epoch)',
              value: state.lastClaimedEpoch,
            ),
          ]);
        }),
      ),
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({super.key, this.message, this.margin = 5});

  final String? message;
  final double margin;

  @override
  Widget build(BuildContext context) {
    return message == null
        ? SizedBox()
        : message!.isEmpty
            ? SizedBox()
            : Container(
                margin: EdgeInsets.all(margin),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.error,
                          spreadRadius: 1.0,
                          blurRadius: 5)
                    ]),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ]),
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
        child: BlocBuilder<CommissionCubit, CommissionState>(
            buildWhen: (prev, current) =>
                prev.comissionAmount != current.comissionAmount ||
                prev.comissionAmountMxc != current.comissionAmountMxc,
            builder: (context, state) {
              return Column(children: [
                const Row(children: [SizedBox(height: 10)]),
                Text(
                  'Available Commission: ${state.comissionAmountMxc} MXC',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: state.comissionAmount == BigInt.zero
                      ? null
                      : () {
                          final CommissionCubit cubit = context.read<CommissionCubit>();
                          cubit.startClaim().then((aResult) {
                            if ((aResult == false) && (context.mounted)) {
                              MessageBox.show(
                                  context,
                                  'ERROR',
                                  'Cannot start the transaction.\n${cubit.lastError}',
                                  400);
                            }
                          });
                        },
                  child: const Text('Claim'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  child: const Text('Exit'),
                  onPressed: () {
                    routes.backToHome();
                  },
                ),
                const SizedBox(height: 10),
              ]);
            }),
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
        child: BlocBuilder<CommissionCubit, CommissionState>(builder: (context, state) {
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
