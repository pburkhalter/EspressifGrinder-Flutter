import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../state/setup_state.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunSetupPage extends ConsumerStatefulWidget {
  final VoidCallback onNextPressed;

  const FirstrunSetupPage({
    Key? key,
    required this.onNextPressed,
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
    if (deviceSetupState.processStep == 0) {
      final deviceSetupState = ref.read(deviceSetupProvider);
      ref.read(deviceSetupProvider.notifier).setupDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/settings.svg',
      width: 120,
      height: 120,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Center(child: illustration)),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleText(text: "Almost there", padding: 10),
                    const DescriptionText(text: "Just a moment. We're setting up the device...", padding: 10),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(color: Colors.black,),
                    const SizedBox(height: 50),
                    Text("${deviceSetupState.processStep}/7 "),
                    const SizedBox(height: 10),
                    Text(deviceSetupState.statusMessage,
                    textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
