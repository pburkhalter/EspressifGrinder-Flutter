import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/description.dart';
import '../../widgets/title.dart';
import '../../state/setup_state.dart';



class SSIDField extends ConsumerWidget {
  const SSIDField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(hintText: 'SSID'),
      onChanged: (ssid) => ref.read(deviceSetupProvider.notifier).wifiAccessPoint = ssid,
    );
  }
}

class PasswordField extends ConsumerStatefulWidget {
  const PasswordField({Key? key}) : super(key: key);

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends ConsumerState<PasswordField> {
  bool _isObscured = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
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
  final Function(String) onButtonTextChange;
  final Function(bool) onButtonVisibilityChange;


  const FirstrunWifiPage({
    Key? key,
    required this.onNextPressed,
    required this.onButtonTextChange,
    required this.onButtonVisibilityChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget illustration = SvgPicture.asset(
      'assets/images/wifi.svg',
      width: 120,
      height: 120,
    );

    onButtonTextChange("Next");
    onButtonVisibilityChange(true);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const SizedBox(height: 25),
            Center(child: illustration),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20), // Apply padding here
              constraints: const BoxConstraints(maxWidth: 350), // Apply constraints here
              height: 390,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    TitleText(text: title, padding: 10),
                    DescriptionText(text: descriptionFactory, padding: 25),
                    const SizedBox(height: 10),
                    const SSIDField(),
                    const SizedBox(height: 10),
                    const PasswordField(),
                ]
              ),
            )
            ]
        )
      )
    )
    );
  }
}
