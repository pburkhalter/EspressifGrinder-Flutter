import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Instructions extends ConsumerWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String title = "Getting the device ready";
    const String descriptionConnect =
        "To enable connection mode, flip the dip-switch three times within five seconds. This will allow the device to connect for five minutes...";
    const String descriptionNote = "The LED will flash repeatedly while the connection mode is active.";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Center(
          child: SvgPicture.asset(
            'assets/images/dip_switch.svg',
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
          textAlign: TextAlign.center,
        ),
        const Text(
          descriptionConnect,
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const Text('Please note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Text(
          descriptionNote,
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
