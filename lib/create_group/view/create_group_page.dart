import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../create_group.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateGroupCubit(
        tickerCheck: const Ticker(name: 'CreateGroupCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
      ),
      // child: const MediaWrapper(child: CreateGroupPageView()),
      child: CreateGroupPageView(),
    );
  }
}

class CreateGroupPageView extends StatelessWidget {
  const CreateGroupPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.home), onPressed: routes.backToHome),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<CreateGroupCubit, CreateGroupState>(
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
    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
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
    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
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
    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
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
          OutlinedButton(
            child: const Text('Create'),
            onPressed: () {
              final CreateGroupCubit cubit = context.read<CreateGroupCubit>();
              cubit.startCreateGroup().then((aResult) {
                if ((aResult == false) && (context.mounted)) {
                  MessageBox.show(context, 'ERROR',
                      'Cannot start the transaction.\n${cubit.lastError}', 400);
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
        child: BlocBuilder<CreateGroupCubit, CreateGroupState>(
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
