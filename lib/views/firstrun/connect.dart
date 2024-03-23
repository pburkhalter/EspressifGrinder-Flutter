import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_settings/app_settings.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';
import 'firstrun.dart';


class FirstrunConnectPage extends ConsumerStatefulWidget {

  const FirstrunConnectPage({Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunConnectPageState();
}


class _FirstrunConnectPageState extends ConsumerState<FirstrunConnectPage> {
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
    setupNotifier.setNavButtonVisibility(false);

    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/wifi?page=3");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    deviceSetupState.navButtonText = "Next";
    deviceSetupState.showNavButton = true;
    deviceSetupState.showNextPageArrow = true;
    deviceSetupState.showPrevPageArrow = true;

    const String title = "Set up Connection";
    const String descriptionConnect = "Switch to settings and connect to the WiFi with the following credentials...";
    const String descriptionNote = "After you successfully connect to the WiFi, you can proceed to the next step.";


    final Widget illustration = SvgPicture.asset(
      'assets/images/connect.svg', width: 120, height: 120,);

    return FirstrunPage(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Center(child: illustration),
          const SizedBox(height: 25),
          Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleText(text: title, padding: 20),
                    const DescriptionText(
                      text: descriptionConnect, padding: 15,),
                    const Text('SSID: CoffeeGrinder', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text('Password: C0ff3Gr1nd3r', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    CustomElevatedButton(
                      buttonText: 'Open Settings', onPressed: () =>
                        AppSettings.openAppSettings(
                            type: AppSettingsType.wifi),),
                    SizedBox(height: 10),
                    const DescriptionText(text: descriptionNote)
                  ])))
        ]));
  }
}
