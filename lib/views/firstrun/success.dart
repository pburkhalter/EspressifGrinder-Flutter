import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/setup_provider.dart';
import 'firstrun.dart';


class FirstrunSuccessPage extends ConsumerStatefulWidget {

  const FirstrunSuccessPage({Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstrunSuccessPageState();
}


class _FirstrunSuccessPageState extends ConsumerState<FirstrunSuccessPage> {
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

    setupNotifier.setNavButtonText("Done");
    setupNotifier.setNavRoute("/device?page=6");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSetupState = ref.watch(deviceSetupProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/coffee_cup.svg', width: 200, height: 200,);

    const String title = "Success";
    const String description = "You're all set!";

    return FirstrunPage(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: Center(child: illustration)),
          Expanded(flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // Apply padding here
                constraints: const BoxConstraints(maxWidth: 350),
                // Apply constraints here
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(
                        fontSize: 48, height: 1.1, letterSpacing: -2),
                      textAlign: TextAlign.center,),
                    SizedBox(height: 15),
                    Text(description, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),),
                  ],),))
        ]));
  }
}
