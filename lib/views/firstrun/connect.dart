import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_settings/app_settings.dart';

import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunConnectPage extends StatelessWidget {
  final String title = "Set up Connection";
  final String descriptionFactory =
      "Use the following credentials to connect to the WiFi of the Grinder and set it up.";
  final String descriptionNote =
      "If the device is already connected to the home network, you can skip this step.";

  final VoidCallback onNextPressed;
  final Function(String) onButtonTextChange;
  final Function(bool) onButtonVisibilityChange;

  const FirstrunConnectPage(
      {Key? key,
      required this.onNextPressed,
      required this.onButtonTextChange,
      required this.onButtonVisibilityChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/wifi.svg',
      width: 120,
      height: 120,
    );

    onButtonTextChange("Next");
    onButtonVisibilityChange(true);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              const SizedBox(height: 20),
              Center(child: illustration),
              const SizedBox(height: 20),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TitleText(text: title, padding: 20),
                            DescriptionText(
                              text: descriptionFactory,
                              padding: 15,
                            ),
                            const SizedBox(height: 20),
                            const Text('SSID: CoffeeGrinder',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const Text('Password: C0ff3Gr1nd3r',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            CustomElevatedButton(
                              buttonText: 'Open Settings',
                              onPressed: () => AppSettings.openAppSettings(
                                  type: AppSettingsType.wifi),
                            ),
                            DescriptionText(
                              text: descriptionNote,
                              padding: 15,
                            )
                          ])))
            ])));
  }
}
