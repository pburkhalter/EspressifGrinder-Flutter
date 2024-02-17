import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../state/setup_state.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunSetupPage extends ConsumerWidget {
  final VoidCallback onNextPressed;

  const FirstrunSetupPage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    // Ensure the device setup is initiated only once when the widget is first built
    if (deviceSetupState.selectedDevice != null && deviceSetupState.processStep == 0) {
      ref.read(deviceSetupProvider.notifier).setupDevice(deviceSetupState.selectedDevice!);
    }

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

                    CircularProgressIndicator(
                      value: deviceSetupState.processStep / 6, // Update to use processStep from state
                      color: Colors.black,
                    ),

                    const SizedBox(height: 25),

                    Text("${deviceSetupState.processStep}/7 ${deviceSetupState.statusMessage}"),
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
