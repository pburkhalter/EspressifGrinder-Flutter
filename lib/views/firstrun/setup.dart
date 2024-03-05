import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';
import 'firstrun.dart';

class FirstrunSetupPage extends ConsumerStatefulWidget {
  const FirstrunSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunSetupPageState();
}

class _FirstrunSetupPageState extends ConsumerState<FirstrunSetupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      configureSetupPageState();
      startSetupProcess();
    });
  }

  void startSetupProcess() {
    final deviceSetupState = ref.read(deviceSetupProvider);
    if (!deviceSetupState.setupIsRunning && !deviceSetupState.setupFinished) {
      ref.read(deviceSetupProvider.notifier).startDeviceSetup();
    }
  }

  void watchSetupProcess() {
    ref.listen<DeviceSetupState>(deviceSetupProvider, (_, state) {
      if (state.setupFinished) {
        context.go('/firstrun/success?page=5');
      }
      if (state.errorMessage != '') {
        context.go('/firstrun/error?page=5');
      }
    });
  }

  void configureSetupPageState() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(false);
    setupNotifier.setNavButtonVisibility(false);

    setupNotifier.setNavRoute("/firstrun/success");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);
    final Widget illustration = SvgPicture.asset(
      'assets/images/settings.svg',
      width: 120,
      height: 120,
    );

    watchSetupProcess();

    return FirstrunPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(child: illustration),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TitleText(text: "Almost there", padding: 20),
                const DescriptionText(
                    text: "Just a moment. We're setting up the device...",
                    padding: 20),
                const SizedBox(height: 50),
                const CircularProgressIndicator(color: Colors.black),
                const SizedBox(height: 50),
                Text("${deviceSetupState.currentSetupStep}/8"),
                const SizedBox(height: 10),
                Text(deviceSetupState.statusMessage,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
