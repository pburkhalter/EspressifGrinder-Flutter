import 'package:app_settings/app_settings.dart';
import 'package:espressif_grinder_flutter/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Connect extends ConsumerWidget {
  const Connect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String title = "Set up Connection";
    const String descriptionConnect = "Switch to settings and connect to the WiFi with the following credentials...";
    const String descriptionNote = "After you successfully connect to the WiFi, you can proceed to the next step.";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Center(
          child: SvgPicture.asset(
            'assets/images/connect.svg',
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
        const Text(
          descriptionConnect,
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const Text('SSID: CoffeeGrinder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Text('Password: C0ff3Gr1nd3r', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        CustomElevatedButton(
          buttonText: 'Open Settings',
          onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
        ),
        const SizedBox(height: 10),
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
