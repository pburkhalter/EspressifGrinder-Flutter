import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/button.dart';

class FirstrunSuccessPage extends StatelessWidget {
  final String title = "Success";
  final String description = "You're all set!";
  final VoidCallback onFinishPressed;

  const FirstrunSuccessPage({
    Key? key,
    required this.onFinishPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/coffee_cup.svg',
      width: 200,
      height: 200,
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
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 48,
                          height: 1.1,
                          letterSpacing: -2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: CustomElevatedButton(
                    buttonText: 'Start',
                    onPressed: onFinishPressed
                )
            )
          ]
        )
      )
    );
  }
}
