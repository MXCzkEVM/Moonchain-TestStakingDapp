import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../miner.dart';

class MinerPage extends StatelessWidget {
  const MinerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MinerCubit(
        tickerCheck: const Ticker(name: 'MinerCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
        localSettingRepos: context.read<LocalSettingRepos>(),
        proverServiceRepos: context.read<ProverServiceRepos>(),
      ),
      // child: const MediaWrapper(child: MinerPageView()),
      child: MinerPageView(),
    );
  }
}

class MinerPageView extends StatelessWidget {
  const MinerPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miner'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.home), onPressed: routes.backToHome),
      ),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<MinerCubit, MinerState>(
                buildWhen: (prev, current) => prev.waiting != current.waiting,
                builder: (context, state) {
                  return state.waiting
                      ? WaitingBox()
                      : ListView(children: [
                          HeaderInfoPanel(),
                          SizedBox(height: 10),
                          ActionNote(),
                          SizedBox(height: 10),
                          AppTokenPanel(),
                          SizedBox(height: 10),
                          MinerList(),
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
    return BlocBuilder<MinerCubit, MinerState>(builder: (context, state) {
      return Column(
        children: [CircularProgressIndicator(), Text(state.waitingMessage)],
      );
    });
  }
}

class HeaderInfoPanel extends StatelessWidget {
  const HeaderInfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MinerCubit, MinerState>(builder: (context, state) {
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

class AppTokenPanel extends StatelessWidget {
  const AppTokenPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Setting',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(children: [
          const Row(children: [SizedBox(height: 10)]),
          BlocBuilder<MinerCubit, MinerState>(builder: (context, state) {
            return LabeledTextField(
              label: 'appToken',
              initialValue: state.appToken,
              onSubmitted: (aValue) {
                context.read<MinerCubit>().setAppToken(aValue);
              },
            );
          }),
          Text(
            'Please enter the appToken received from the miner registration.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            child: const Text('Save'),
            onPressed: () {
              final MinerCubit cubit = context.read<MinerCubit>();
              cubit.saveSetting().then((aResult) {
                if (context.mounted) {
                  if (aResult == false) {
                    MessageBox.show(context, 'ERROR',
                        'Save setting failed.\n${cubit.lastError}', 400);
                  } else {
                    MessageBox.show(context, 'INFO', 'Setting saved.', 400)
                        .then((_) {
                      routes.popAndPushNamed(Routes.miner);
                    });
                  }
                }
              });
            },
          ),
          const SizedBox(height: 10),
        ]),
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

class ActionNote extends StatelessWidget {
  const ActionNote({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Note',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(children: [
          const Row(children: [SizedBox(height: 10)]),
          const Text(
              'Miner registration is not available here. Please use the Terminal2 APP to complete the registration and obtain the appToken.'),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class MinerList extends StatelessWidget {
  MinerList({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text('Miner List',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold))),
      ]),
      Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: BlocBuilder<MinerCubit, MinerState>(builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    "Total ${state.minerCount}",
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
                          itemCount: state.minerList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MinerInfoBox(
                              item: state.minerList[index],
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

class MinerInfoBox extends StatelessWidget {
  const MinerInfoBox({super.key, required this.item, this.onTap});

  final UiMinerInfo item;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Column(children: [
          Text("Instance ID ${item.instanceId}",
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Last Ping: ${item.lastPing}'),
          Text('Online: ${item.online}'),
        ]),
      ),
    );
  }
}
