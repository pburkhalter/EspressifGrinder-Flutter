import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_settings/app_settings.dart';

import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';
import '../../state/setup_state.dart';



class SSIDField extends ConsumerWidget {
  const SSIDField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(hintText: 'SSID'),
      onChanged: (ssid) => ref.read(deviceSetupProvider.notifier).updateWifiAccessPoint(ssid),
    );
  }
}

class PasswordField extends ConsumerWidget {
  const PasswordField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool _isObscured = true;

    void _togglePasswordVisibility() {
      _isObscured = !_isObscured;
      // Force widget to rebuild and update its state
      (context as Element).markNeedsBuild();
    }

    return TextField(
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      onChanged: (password) => ref.read(deviceSetupProvider.notifier).updateWifiPassword(password),
    );
  }
}

class FirstrunWifiPage extends ConsumerWidget {
  final String title = "Set up Wifi";
  final String descriptionFactory = "Enter the credentials of the Wifi the Device should connect to.";
  final String descriptionNote = "TODO";
  final VoidCallback onNextPressed;

  const FirstrunWifiPage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/wifi.svg',
      width: 120,
      height: 120,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                illustration,
                SizedBox(height: 20),
                TitleText(text: title, padding: 10),
                DescriptionText(text: descriptionFactory, padding: 15),
                SizedBox(height: 10),
                SSIDField(),
                SizedBox(height: 10),
                PasswordField(),
                SizedBox(height: 20),
                CustomElevatedButton(buttonText: 'Next', onPressed: onNextPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
