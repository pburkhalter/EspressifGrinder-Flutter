import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunInstructionsPage extends StatelessWidget {
  final String title = "Getting the device ready";
  final String descriptionConnect = "To enable connection mode, flip the dip-switch three times within five seconds. This will allow the device to connect for five minutes...";
  final String descriptionNote = "The LED will flash repeatedly while the connection mode is active.";

  final VoidCallback onNextPressed;

  const FirstrunInstructionsPage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/dip_switch.svg',
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
                      flex: 2,
                      child: Center(child: illustration)
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20), // Apply padding here
                          constraints: const BoxConstraints(maxWidth: 300), // Apply constraints here
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TitleText(
                                    text: title,
                                    padding: 10),
                                DescriptionText(
                                    text: descriptionConnect,
                                    padding: 20,
                                ),
                                const Text(
                                  'Please note',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                DescriptionText(
                                    text: descriptionNote,

                                )
                              ]
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: CustomElevatedButton(
                          buttonText: 'Start',
                          onPressed: onNextPressed
                      )
                  )
                ]
            )
        )
    );
  }
}