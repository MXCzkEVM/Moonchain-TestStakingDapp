import 'package:flutter/material.dart';

import 'package:dapp/home/home.dart';
import 'package:dapp/stake/stake.dart';
import 'package:dapp/stake_to_group/stake_to_group.dart';
import 'package:dapp/claim/claim.dart';
import 'package:dapp/withdraw/withdraw.dart';
import 'package:dapp/create_group/create_group.dart';
import 'package:dapp/miner/miner.dart';

import '../shared/media_wrapper.dart';

class Routes {
  final navigatorKey = GlobalKey<NavigatorState>();

  static const double desginedWidth = 450;

  static const String home = '/home';
  static const String stake = '/stake';
  static const String stakeToGroup = '/stakeToGroup';
  static const String claim = '/claim';
  static const String withdraw = '/withdraw';
  static const String createGroup = '/createGroup';
  static const String miner = '/miner';

  Map<String, Widget Function(BuildContext)> get() {
    return {
      home: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: HomePage()),
      stake: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: StakePage()),
      stakeToGroup: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: StakeToGroupPage()),
      claim: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: ClaimPage()),
      withdraw: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: WithdrawPage()),
      createGroup: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: CreateGroupPage()),
      miner: (_) =>
          const MediaWrapper(desginedWidth: desginedWidth, child: MinerPage()),
    };
  }

  void backToHome() {
    navigatorKey.currentState!.popUntil((route) => true);
    navigatorKey.currentState!.popAndPushNamed(home);
    // navigatorKey.currentState!
    //     .pushNamedAndRemoveUntil(Routes.home, (route) => true);
  }

  void popAndPushNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState!.popAndPushNamed(routeName, arguments: arguments);
  }
}

final routes = Routes();
