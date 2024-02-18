import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_settings/app_settings.dart';

import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunConnectPage extends StatelessWidget {
  final String title = "Set up Connection";
  final String descriptionFactory = "Us the following credentials to connect to the WiFi of the Grinder and set it up.";
  final String descriptionNote = "If the device is already connected to the home network, skip this step.";

  final VoidCallback onNextPressed;

  const FirstrunConnectPage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/wifi.svg',
      width: 120,
      height: 120,
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 4,
                      child: Center(child: illustration)
                  ),
                  Expanded(
                    flex: 10,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TitleText(
                                    text: title,
                                    padding: 10),
                                DescriptionText(
                                  text: descriptionFactory,
                                  padding: 15,
                                ),
                                const Text(
                                    'SSID: CoffeeGrinder',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                const Text(
                                    'Password: C0ff3Gr1nd3r',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                CustomElevatedButton(
                                    buttonText: 'Open Settings',
                                    onPressed: () => AppSettings.openAppSettings(type:AppSettingsType.wifi),
                                ),
                                DescriptionText(
                                  text: descriptionNote,
                                  padding: 10,
                                )
                              ]
                          )
                      )
                  ),
                  Expanded(
                      flex: 2,
                      child: CustomElevatedButton(
                          buttonText: 'Next',
                          onPressed: onNextPressed
                      )
                  )

                ]
            )
        )
    );
  }
}
