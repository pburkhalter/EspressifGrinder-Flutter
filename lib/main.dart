import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '/views/firstrun/firstrun.dart';


Future<bool> isFirstRun() async {
  var configService = ConfigService();
  await configService.copyConfigFile();

  return !(await configService.get('firstrun_done'));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var configService = ConfigService();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      home: FutureBuilder<bool>(
        future: isFirstRun(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading configuration'));
            }
            // Navigate to FirstrunProcess if firstrun_done is false or not set
            if (snapshot.data == true) {
              return const FirstrunProcess();
            } else {
              return const MainScreen();
            }
          } else {
            // Show loading spinner while checking configuration
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Setup'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FirstrunProcess()),
            );
          },
        ),
      ),
    );
  }
}
