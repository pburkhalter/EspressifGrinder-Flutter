import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Welcome extends ConsumerWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const title = 'Hey there!';
    const description = "Let's take a moment to configure some important settings, before we begin using the app.";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Center(
          child: SvgPicture.asset(
            'assets/images/coffee_beans.svg',
            width: 150,
            height: 150,
          ),
        ),
        const SizedBox(height: 100),
        const Text(
          title,
          style: TextStyle(
            fontSize: 40,
            height: 1.1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          description,
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
