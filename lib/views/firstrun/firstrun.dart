import 'package:espressif_grinder_flutter/views/firstrun/wifi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/setup_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/page_indicator.dart';

class FirstrunPage extends ConsumerStatefulWidget {
  final Widget child;

  const FirstrunPage({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FirstrunPageState();
}

class FirstrunPageState extends ConsumerState<FirstrunPage> {

  final int _numPages = 6;

  void goToPage() {
    final deviceSetupState = ref.read(deviceSetupProvider);
    context.go(deviceSetupState.navRoute);
  }

  void goToPrevPage() {
    context.pop();
  }

  void goToNextPage() {
    //context.push();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Consumer(builder: (context, ref, _) {
        final deviceSetupState = ref.watch(deviceSetupProvider);
        return _buildTopNavigation(deviceSetupState);
      })),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: widget.child,
            ),
            _buildBottomNavigation()
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(DeviceSetupState deviceSetupState) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: deviceSetupState.showPrevPageArrow,
            child: IconButton(
              onPressed: goToPrevPage,
              icon: const Icon(Icons.arrow_back, size: 32),
            ),
          ),
          const Text(
            'EspressifGrinder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Visibility(
            visible: deviceSetupState.showNextPageArrow,
            child: IconButton(
              onPressed: goToNextPage,
              icon: const Icon(Icons.arrow_forward, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    String? currentPage = GoRouterState.of(context).uri.queryParameters['page'];

    return Consumer(builder: (context, ref, _) {
      final deviceSetupState = ref.watch(deviceSetupProvider);
      return Column(
        children: [
          Visibility(
              visible: deviceSetupState.showNavButton,
              child: CustomElevatedButton(
                buttonText: deviceSetupState.navButtonText,
                onPressed: deviceSetupState.navButtonEnabled ? goToPage : null,
              )
          ),
          PageIndicator(
            totalPages: _numPages,
            currentPage: int.parse(currentPage ?? '0'),
          )
        ],
      );
    });
  }

}





