import "package:dapp/shared/media_wrapper.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:dapp/singletons/appdata.dart";
import "package:dapp/splash/splash.dart";
import "package:dapp/repository/repository.dart";
import "package:dapp/singletons/routes.dart";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<L1Repository>(
          create: (context) => L1Repository(),
          lazy: false,
        ),
        RepositoryProvider<LocalSettingRepos>(
          create: (context) => LocalSettingRepos(),
          lazy: false,
        ),
        RepositoryProvider<ProverServiceRepos>(
          create: (context) => ProverServiceRepos(),
          lazy: false,
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: routes.navigatorKey,
        initialRoute: Routes.home,
        routes: routes.get(),
        onGenerateRoute: (_) => SplashPage.route(),
        theme: appData.theme, 
    );
  }
}
