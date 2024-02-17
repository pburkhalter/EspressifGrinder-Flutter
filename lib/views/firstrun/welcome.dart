import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';

class FirstrunWelcomePage extends StatelessWidget {
  final String title = "Hey there!";
  final String description = "Let's take a moment to configure some important settings, before we begin using the app.";
  final VoidCallback onNextPressed;

  const FirstrunWelcomePage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/coffee_beans.svg',
      width: 150,
      height: 150,
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
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20), // Apply padding here
                constraints: const BoxConstraints(maxWidth: 300), // Apply constraints here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleText(
                        text: title,
                        padding: 16),
                    DescriptionText(
                      text: description
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
