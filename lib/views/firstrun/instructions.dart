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
  final Function(String) onButtonTextChange;
  final Function(bool) onButtonVisibilityChange;



  const FirstrunInstructionsPage({
    Key? key,
    required this.onNextPressed,
    required this.onButtonTextChange,
    required this.onButtonVisibilityChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/dip_switch.svg',
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
                const SizedBox(height: 25),
            Center(child: illustration),
            const SizedBox(height: 25),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20), // Apply padding here
                          constraints: const BoxConstraints(maxWidth: 350), // Apply constraints here
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TitleText(
                                    text: title,
                                    padding: 20),
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
                  )
                ]
            )
        )
    );
  }
}
