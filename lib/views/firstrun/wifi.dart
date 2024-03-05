import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/description.dart';
import '../../widgets/title.dart';
import 'firstrun.dart';


class SSIDField extends ConsumerWidget {
  const SSIDField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(decoration: const InputDecoration(hintText: 'SSID'),
    onChanged: (ssid) => ref.read(deviceSetupProvider.notifier).updateWifiAccessPoint(ssid));

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
    return TextField(obscureText: _isObscured,
      decoration: InputDecoration(labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: _togglePasswordVisibility)),
          onChanged: (password) => ref.read(deviceSetupProvider.notifier).updateWifiPassword(password));

  }
}


class FirstrunWifiPage extends ConsumerStatefulWidget {

  const FirstrunWifiPage({Key? key,}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunWifiPageState();
}


class _FirstrunWifiPageState extends ConsumerState<FirstrunWifiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      configureSetupPageState();
    });
  }

  void configureSetupPageState() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(true);

    setupNotifier.setNavButtonVisibility(true);
    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/setup?page=4");

    setupNotifier.updateNavButtonEnabledState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/wifi.svg', width: 120, height: 120,);

    const String title = "Set up Wifi";
    const String descriptionFactory = "Enter the credentials of the Wifi the Device should connect to.";

    return FirstrunPage(child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Center(child: illustration),
          const SizedBox(height: 25),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 350),
            height: 390,
            child: const Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  TitleText(text: title, padding: 10),
                  DescriptionText(text: descriptionFactory, padding: 25),
                  SizedBox(height: 10),
                  SSIDField(),
                  SizedBox(height: 10),
                  PasswordField(),
                ]),)
        ])));
  }
}
