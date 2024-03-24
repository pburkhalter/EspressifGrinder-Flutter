import 'package:espressif_grinder_flutter/providers/setup_provider.dart';
import 'package:espressif_grinder_flutter/views/firstrun/connect.dart';
import 'package:espressif_grinder_flutter/views/firstrun/instructions.dart';
import 'package:espressif_grinder_flutter/views/firstrun/welcome.dart';
import 'package:espressif_grinder_flutter/views/firstrun/wifi.dart';
import 'package:espressif_grinder_flutter/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

class WelcomeFlowPage extends ConsumerStatefulWidget {
  const WelcomeFlowPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => WelcomeFlowPageState();
}

class WelcomeFlowPageState extends ConsumerState {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final deviceSetup = ref.watch(deviceSetupProvider);

    final hasSSIDAndPass = deviceSetup.wifiAccessPoint.isNotEmpty && deviceSetup.wifiPassword.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: PageView(
                controller: controller,
                children: const [
                  SingleChildScrollView(
                    child: Welcome(),
                  ),
                  SingleChildScrollView(
                    child: Instructions(),
                  ),
                  SingleChildScrollView(
                    child: Connect(),
                  ),
                  SingleChildScrollView(
                    child: Wifi(),
                  ),
                ],
                onPageChanged: (int page) {
                  ref.read(currentPageProvider.notifier).state = page;
                },
              ),
            ),
            CustomElevatedButton(
              buttonText: 'Next',
              onPressed: currentPage == 3 && !hasSSIDAndPass
                  ? null
                  : () {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
            ),
            const SizedBox(height: 20),
            PageViewDotIndicator(
              currentItem: currentPage,
              count: 4,
              unselectedColor: Colors.black26,
              selectedColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void welcomeSetup() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(false);
    setupNotifier.setNavButtonVisibility(true);
    setupNotifier.setNavButtonText("Start");
    setupNotifier.setNavRoute("/firstrun/instructions?page=1");
  }

  void setupInstructions() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(true);
    setupNotifier.setPrevPageArrowVisibility(true);
    setupNotifier.setNavButtonVisibility(true);
    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/connect?page=2");
  }

  void setupConnect() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(false);
    setupNotifier.setNavButtonVisibility(false);

    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/wifi?page=3");
  }

  void setupWifi() {
    final setupNotifier = ref.read(deviceSetupProvider.notifier);
    setupNotifier.setNextPageArrowVisibility(false);
    setupNotifier.setPrevPageArrowVisibility(true);

    setupNotifier.setNavButtonVisibility(true);
    setupNotifier.setNavButtonText("Next");
    setupNotifier.setNavRoute("/firstrun/setup?page=4");

    setupNotifier.updateNavButtonEnabledState();
  }
}
