import 'package:espressif_grinder_flutter/providers/setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SSIDField extends ConsumerWidget {
  const SSIDField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(hintText: 'SSID'),
      onChanged: (ssid) => ref.read(deviceSetupProvider.notifier).updateWifiAccessPoint(ssid),
    );
  }
}
