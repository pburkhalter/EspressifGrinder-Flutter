import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/device.dart';
import '../../state/discover_state.dart';
import '../../widgets/button.dart';
import '../../widgets/description.dart';
import '../../widgets/device_list_view.dart';
import '../../widgets/title.dart';


class DiscoveryMessageWidget extends StatelessWidget {
  final String message;

  const DiscoveryMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DescriptionText(
        text: message,
        padding: 10,
      ),
    );
  }
}


class FirstrunDevicePage extends ConsumerWidget {
  final VoidCallback onNextPressed;

  const FirstrunDevicePage({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceDiscoveryState = ref.watch(deviceDiscoveryProvider);

    final Widget illustration = SvgPicture.asset(
      'assets/images/connect.svg',
      width: 120,
      height: 120,
    );

    // Ensure the device search is initiated only once when the widget is first built
    // and when there are no devices already discovered.
    if (!deviceDiscoveryState.isLoading &&
        deviceDiscoveryState.availableDevices.isEmpty &&
        !deviceDiscoveryState.hasSearched) {
      Future.microtask(
            () => ref.read(deviceDiscoveryProvider.notifier).discoverDevices(),
      );
    }


    // Conditional rendering based on the device discovery state
    Widget content;
    if (deviceDiscoveryState.isLoading) {
      content = _buildLoadingView();
    } else if (deviceDiscoveryState.availableDevices.isEmpty) {
      content = _buildEmptyView();
    } else {
      // Pass ref to the method
      content = _buildDeviceListView(deviceDiscoveryState.availableDevices, onNextPressed, ref);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex: 3,
                child: Center(child: illustration)
            ),
            Expanded(flex: 4, child: Center(child: content)),
            Expanded(
              flex: 1,
              child: Visibility(
                visible: !deviceDiscoveryState.isLoading, // Condition to show/hide the button
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: CustomElevatedButton(
                  buttonText: 'Search again...',
                  onPressed: () => ref.read(deviceDiscoveryProvider.notifier).discoverDevices(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Column(
      key: ValueKey('searching'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleText(text: "Devices", padding: 16),
        DescriptionText(text: "Searching for devices...", padding: 20),
        SizedBox(height: 20),
        CircularProgressIndicator(color: Colors.black),
      ],
    );
  }

  Widget _buildEmptyView() {
    return const Column(
      key: ValueKey('noDevices'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleText(text: "No Devices Found", padding: 16),
        DescriptionText(text: "No devices found in your network.", padding: 20),
      ],
    );
  }

  Widget _buildDeviceListView(List<Device> devices, VoidCallback onNextPressed, WidgetRef ref) {
    return Column(
      children: [
        const DiscoveryMessageWidget(
          message: "Below are the devices we discovered in your network. Please select the appropriate device to continue the setup.",
        ),
        Expanded(
          child: DeviceListView(
            devices: devices,
            onDeviceTap: (Device device) {
              // Call selectDevice on DeviceSelectedNotifier
              onNextPressed(); // If you have additional logic to execute after selecting the device
            },
          ),
        ),
      ],
    );
  }

}
