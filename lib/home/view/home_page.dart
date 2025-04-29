import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dapp/shared/widgets.dart';
import 'package:dapp/shared/message_box.dart';
import 'package:dapp/shared/ticker.dart';
import 'package:dapp/repository/repository.dart';
import 'package:dapp/singletons/routes.dart';

import '../home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        tickerCheck: const Ticker(name: 'HomeCheck', intervalInMs: 5000),
        l1Repository: context.read<L1Repository>(),
        localSettingRepos: context.read<LocalSettingRepos>(),
        proverServiceRepos: context.read<ProverServiceRepos>(),
      ),
      // child: const MediaWrapper(child: HomePageView()),
      child: HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        leading: Container(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (prev, current) =>
                  prev.isNetworkConnected != current.isNetworkConnected ||
                  prev.waiting != current.waiting ||
                  prev.isTargetChain != current.isTargetChain,
              builder: (context, state) {
                return state.waiting
                    ? CircularProgressIndicator()
                    : state.isNetworkConnected
                        ? ListView(children: [
                            HeaderInfoPanel(),
                            SizedBox(height: 10),
                            state.isTargetChain
                                ? StakingPoolInfo()
                                : SizedBox(),
                            SizedBox(height: 10),
                            state.isTargetChain ? MyStakingInfo() : SizedBox(),
                            SizedBox(height: 10),
                            state.isTargetChain ? BalancePanel() : SizedBox(),
                            SizedBox(height: 10),
                            state.isTargetChain ? ButtonPanel() : SizedBox(),
                            SizedBox(height: 10),
                            ChainInfoPanel(),
                            SizedBox(height: 10),
                            state.isTargetChain
                                ? SizedBox()
                                : Text(
                                    '!! Please switch to Arbitrum.',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                          ])
                        : ListView(children: [
                            Row(children: [
                              ElevatedButton(
                                onPressed: state.waiting
                                    ? null
                                    : () {
                                        final bloc = context.read<HomeCubit>();
                                        bloc.connectMetamask().then((result) {
                                          if ((context.mounted) && (!result)) {
                                            MessageBox.show(
                                                context,
                                                'ERROR',
                                                'Connect Metamask failed.\n${bloc.lastError}',
                                                400);
                                          }
                                        });
                                      },
                                child: state.waiting
                                    ? const Text('Connecting')
                                    : const Text('Connect Metamask'),
                              ),
                            ]),
                          ]);
              }),
        ),
      ),
    );
  }
}

class HeaderInfoPanel extends StatelessWidget {
  const HeaderInfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
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

class ChainInfoPanel extends StatelessWidget {
  const ChainInfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Chain Info',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return Column(children: [
            LabeledText(
              label: 'ethers Version',
              value: state.ethersVersion,
            ),
            LabeledText(
              label: 'Chain ID',
              value:
                  '${state.chainId.toString()}\n${state.chainName} ${state.isTestnet ? '(Testnet)' : ''}',
            ),
            LabeledText(
              label: 'Block Number',
              value: state.blockNumber.toString(),
            ),
            LabeledText(
              label: 'TaikoL1 Contract',
              value: state.taikoL1Address,
              selectable: true,
              valueFontSize: 11,
              fontFamily: 'RobotoMono',
            ),
            LabeledText(
              label: 'L1Staking Contract',
              value: state.l1StakingAddress,
              selectable: true,
              valueFontSize: 11,
              fontFamily: 'RobotoMono',
            ),
            LabeledText(
              label: 'MxcToken Contract',
              value: state.mxcTokenAddress,
              selectable: true,
              valueFontSize: 11,
              fontFamily: 'RobotoMono',
            ),
            LabeledText(
              label: 'ZkCenter Contract',
              value: '${state.zkCenterAddress} (${state.zkCenterName2})',
              selectable: true,
              valueFontSize: 11,
              fontFamily: 'RobotoMono',
            ),
          ]);
        }),
      ),
    );
  }
}

class StakingPoolInfo extends StatelessWidget {
  const StakingPoolInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Staking Pool',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return Column(children: [
            LabeledText(
              label: 'Total Staked Amount',
              value: '${state.stakingPoolInfo.totalAmountMxc} MXC',
            ),
            LabeledText(
              label: 'Reward balance',
              value: '${state.stakingPoolInfo.rewardBalanceMxc} MXC',
            ),
            LabeledText(
              label: 'Last Deposit Reward Time',
              value: state.stakingPoolInfo.lastDepositRewardTime.toString(),
            ),
            LabeledText(
              label: 'Reward Beginning Epoch',
              value: state.stakingPoolInfo.rewardBeginEpoch,
            ),
            LabeledText(
              label: 'Current Epoch',
              value: state.stakingPoolInfo.currentEpoch,
            ),
          ]);
        }),
      ),
    );
  }
}

class MyStakingInfo extends StatelessWidget {
  const MyStakingInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'My Staking',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return Column(children: [
            LabeledText(
              label: 'Staked Amount',
              value: '${state.userStakeStatus.stakingBalancesMxc} MXC',
            ),
            LabeledText(
              label: 'Staking Group',
              value: state.userStakeStatus.stakingGroupId == BigInt.zero
                  ? 'No group'
                  : '${state.userStakeStatus.stakingGroupId}${state.userStakeStatus.isGroupLeader ? ' [Leader]' : ''}',
            ),
            LabeledText(
              label: 'Last Claim (Epoch)',
              value: state.userStakeStatus.strLastClaimedEpoch,
            ),
            LabeledText(
              label: 'Withdraw Requested (Epoch)',
              value: state.userStakeStatus.withdrawalRequestEpoch,
            ),
            LabeledText(
              label: 'Gross amount of reward',
              value: '${state.grossRewardMxc} MXC',
            ),
          ]);
        }),
      ),
    );
  }
}

class ButtonPanel extends StatelessWidget {
  const ButtonPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Actions',
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: BlocBuilder<HomeCubit, HomeState>(
            buildWhen: (prev, current) =>
                prev.userStakeStatus != current.userStakeStatus || prev.minerCount != current.minerCount,
            builder: (context, state) {
              return Column(children: [
                const Row(children: [SizedBox(height: 10)]),
                OutlinedButton(
                  onPressed: !state.userStakeStatus.isGroupLeader && state.userStakeStatus.stakingGroupId != BigInt.zero
                      ? null
                      : () {
                          routes.popAndPushNamed(Routes.miner);
                        },
                  child: Text('Miner (owned ${state.minerCount})'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed:
                      (state.userStakeStatus.stakingGroupId != BigInt.zero) || (state.minerCount == 0)
                          ? null
                          : () {
                              routes.popAndPushNamed(Routes.createGroup);
                            },
                  child: const Text('Create Group (Miner Owner)'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: !state.userStakeStatus.isGroupLeader
                      ? null
                      : () {
                          if (state.grossReward != BigInt.zero) {
                            MessageBox.show(
                                context,
                                'ERROR',
                                'Please claim reward first.\nEstimated gross amount is ${state.grossRewardMxc} MXC.',
                                400);
                          } else {
                            routes.popAndPushNamed(Routes.stake);
                          }
                        },
                  child: const Text('Stake (Group Leader)'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: state.userStakeStatus.isGroupLeader
                      ? null
                      : () {
                          if (state.grossReward != BigInt.zero) {
                            MessageBox.show(
                                context,
                                'ERROR',
                                'Please claim reward first.\nEstimated gross amount is ${state.grossRewardMxc} MXC.',
                                400);
                          } else {
                            routes.popAndPushNamed(Routes.stakeToGroup);
                          }
                        },
                  child: const Text('Stake to Group'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    routes.popAndPushNamed(Routes.claim);
                  },
                  child: const Text('Claim'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  child: const Text('Withdraw'),
                  onPressed: () {
                    routes.popAndPushNamed(Routes.withdraw);
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
        child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
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
