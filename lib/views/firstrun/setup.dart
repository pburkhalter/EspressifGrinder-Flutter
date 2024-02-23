import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../state/setup_state.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';


class FirstrunSetupPage extends ConsumerStatefulWidget {
  final VoidCallback onNextPressed;
  final Function(bool) onButtonVisibilityChange;

  const FirstrunSetupPage({
    Key? key,
    required this.onNextPressed,
    required this.onButtonVisibilityChange
  }) : super(key: key);

  @override
  FirstrunSetupPageState createState() => FirstrunSetupPageState();
}

class FirstrunSetupPageState extends ConsumerState<FirstrunSetupPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => startSetupProcess());
  }

  void startSetupProcess() {
    final deviceSetupState = ref.read(deviceSetupProvider);
    if (!deviceSetupState.setupIsRunning && !deviceSetupState.setupFinished) {
      ref.read(deviceSetupProvider.notifier).startDeviceSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    deviceSetupState.nextPageText = "Start";
    deviceSetupState.showNextPageButton = false;
    deviceSetupState.showNextPageArrow = false;
    deviceSetupState.showPrevPageArrow = false;

    final Widget illustration = SvgPicture.asset(
      'assets/images/settings.svg',
      width: 120,
      height: 120,
    );

    widget.onButtonVisibilityChange(false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:SingleChildScrollView(
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
                    const DescriptionText(text: "Just a moment. We're setting up the device...", padding: 20),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(color: Colors.black,),
                    const SizedBox(height: 50),
                    Text("${deviceSetupState.setupStep}/8 "),
                    const SizedBox(height: 10),
                    Text(deviceSetupState.statusMessage,
                    textAlign: TextAlign.center),
                  ],
                ),
              ),
            ]),
        ),
        ),
      );
  }
}
