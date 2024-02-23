import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/description.dart';
import '../../widgets/title.dart';


class FirstrunWelcomePage extends StatelessWidget {
  final String title = "Hey there!";
  final String description = "Let's take a moment to configure some important settings, before we begin using the app.";
  final VoidCallback onNextPressed;


  const FirstrunWelcomePage({
    Key? key,
    required this.onNextPressed
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
            const SizedBox(height: 100),
            Center(child: illustration),
            const SizedBox(height: 100),
            Expanded(
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 350),
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
            )
          ]
        )
      )
    );
  }
}
