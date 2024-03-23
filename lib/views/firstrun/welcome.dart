import 'package:espressif_grinder_flutter/views/firstrun/firstrun.dart';
import 'package:espressif_grinder_flutter/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/description.dart';


class FirstrunWelcomePage extends ConsumerStatefulWidget {
  const FirstrunWelcomePage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunWelcomePageState();
}

class _FirstrunWelcomePageState extends ConsumerState<FirstrunWelcomePage> {
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
    setupNotifier.setPrevPageArrowVisibility(false);
    setupNotifier.setNavButtonVisibility(true);

    setupNotifier.setNavButtonText("Start");
    setupNotifier.setNavRoute("/firstrun/instructions?page=1");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/coffee_beans.svg',
      width: 150,
      height: 150,
    );

    const String title = "Hey there!";
    const String description =
        "Let's take a moment to configure some important settings, before we begin using the app.";

    return FirstrunPage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 100),
      Center(child: illustration),
      const SizedBox(height: 100),
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxWidth: 350),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleText(text: title, padding: 16),
                    DescriptionText(text: description)
                  ])))
    ]));
  }
}
