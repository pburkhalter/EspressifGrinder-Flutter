import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';
import 'firstrun.dart';


class FirstrunInstructionsPage extends ConsumerStatefulWidget {
  const FirstrunInstructionsPage({Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunInstructionsPageState();
}


class _FirstrunInstructionsPageState
    extends ConsumerState<FirstrunInstructionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      configureSetupPageState();
    });
  }

  void configureSetupPageState() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);

    setupNotifier.setNextPageArrowVisibility(true);
    setupNotifier.setPrevPageArrowVisibility(true);
    setupNotifier.setNavButtonVisibility(true);

    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/connect?page=2");
  }

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/dip_switch.svg', width: 120, height: 120,);

    const String title = "Getting the device ready";
    const String descriptionConnect = "To enable connection mode, flip the dip-switch three times within five seconds. This will allow the device to connect for five minutes...";
    const String descriptionNote = "The LED will flash repeatedly while the connection mode is active.";

    return FirstrunPage(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Center(child: illustration),
          const SizedBox(height: 25),
          Expanded(flex: 4,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // Apply padding here
                  constraints: const BoxConstraints(maxWidth: 350),
                  // Apply constraints here
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TitleText(text: title, padding: 20),
                        DescriptionText(text: descriptionConnect, padding: 20,),
                        Text('Please note', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                        DescriptionText(text: descriptionNote,

                        )
                      ])))
        ]));
  }
}
