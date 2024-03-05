import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/setup_provider.dart';
import 'firstrun.dart';

class FirstrunErrorPage extends ConsumerStatefulWidget {
  const FirstrunErrorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunSuccessPageState();
}

class _FirstrunSuccessPageState extends ConsumerState<FirstrunErrorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      configureSetupPageState();
    });
  }

  void configureSetupPageState() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);

    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(false);
    setupNotifier.setNavButtonVisibility(true);

    setupNotifier.setNavButtonText("Reset device");
    setupNotifier.setNavRoute("/firstrun/welcome?page=6");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/error.svg',
      width: 150,
      height: 150,
    );

    const String title = "Oops!";
    const String description =
        "Something went wrong while setting up the device. Try again?";

    return FirstrunPage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 100),
      Center(child: illustration),
      const SizedBox(height: 100),
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      title,
                      style: TextStyle(
                          fontSize: 48, height: 1.1, letterSpacing: -2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        'Reason: ${deviceSetupState.errorMessage!}',
                        textAlign: TextAlign.center,)
                  ])))
    ]));
  }
}
