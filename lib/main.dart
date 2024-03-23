import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:espressif_grinder_flutter/views/welcome_flow_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'views/firstrun/welcome.dart';
import 'views/firstrun/instructions.dart';
import 'views/firstrun/connect.dart';
import 'views/firstrun/wifi.dart';
import 'views/firstrun/setup.dart';
import 'views/firstrun/success.dart';
import 'views/firstrun/error.dart';

import 'views/device.dart';
import 'views/settings.dart';


Future<bool> isFirstRun() async {
  var configService = ConfigService();
  await configService.copyConfigFile();
  return !(await configService.get('firstrun_done'));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool firstRun = await isFirstRun();

  runApp(ProviderScope(child: MyApp(firstRun: firstRun)));
}

class MyApp extends StatelessWidget {
  final bool firstRun;
  const MyApp({super.key, required this.firstRun});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: firstRun ?  '/welcomePage' : '/device', //'/firstrun/welcome?page=0' : '/device',
      routes: [
        GoRoute(
          path: '/welcomePage',
          name: 'welcomePage',
          builder: (BuildContext context, GoRouterState state) => const WelcomePage(),
        ),
        GoRoute(
          path: '/firstrun/welcome',
          name: 'firstrunWelcome',
          builder: (BuildContext context, GoRouterState state) => const FirstrunWelcomePage(),
        ),
        GoRoute(
          path: '/firstrun/instructions',
          name: 'firstrunInstructions',
          builder: (BuildContext context, GoRouterState state) => const FirstrunInstructionsPage(),
        ),
        GoRoute(
          path: '/firstrun/connect',
          name: 'firstrunConnect',
          builder: (BuildContext context, GoRouterState state) => const FirstrunConnectPage(),
        ),
        GoRoute(
          path: '/firstrun/wifi',
          name: 'firstrunWifi',
          builder: (BuildContext context, GoRouterState state) => const FirstrunWifiPage(),
        ),
        GoRoute(
          path: '/firstrun/setup',
          name: 'firstrunSetup',
          builder: (BuildContext context, GoRouterState state) => const FirstrunSetupPage(),
        ),
        GoRoute(
          path: '/firstrun/success',
          name: 'firstrunSuccess',
          builder: (BuildContext context, GoRouterState state) => const FirstrunSuccessPage(),
        ),
        GoRoute(
          path: '/firstrun/error',
          name: 'firstrunError',
          builder: (BuildContext context, GoRouterState state) => const FirstrunErrorPage(),
        ),
        GoRoute(
          path: '/device',
          builder: (BuildContext context, GoRouterState state) => const DevicePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
        ),
      ],
    );

    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
