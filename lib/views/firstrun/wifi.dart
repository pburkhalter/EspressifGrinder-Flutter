import 'package:espressif_grinder_flutter/widgets/password_field.dart';
import 'package:espressif_grinder_flutter/widgets/ssid_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Wifi extends ConsumerWidget {
  const Wifi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String title = "Set up Wifi";
    const String descriptionFactory = "Enter the credentials of the Wifi the Device should connect to.";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Center(
              child: SvgPicture.asset(
            'assets/images/wifi.svg',
            width: 120,
            height: 120,
          )),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 350),
            height: 390,
            child: const Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 40,
                  height: 1.1,
                  letterSpacing: -2,
                ),
              ),
              Text(
                descriptionFactory,
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              SSIDField(),
              SizedBox(height: 10),
              PasswordField(),
            ]),
          )
        ],
      ),
    );
  }
}
