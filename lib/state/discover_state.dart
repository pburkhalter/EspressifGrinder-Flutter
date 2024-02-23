import 'package:espressif_grinder_flutter/services/mdns_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';
import '../services/config_service.dart';


class DeviceDiscoveryState {
  final List<Device> availableDevices;
  final String? errorMessage;
  final bool isLoading;
  final bool hasSearched;

  DeviceDiscoveryState({
    this.availableDevices = const [],
    this.errorMessage,
    this.isLoading = false,
    this.hasSearched = false,
  });

  DeviceDiscoveryState copyWith({
    List<Device>? availableDevices,
    String? errorMessage,
    bool? isLoading,
    bool? hasSearched,
  }) {
    return DeviceDiscoveryState(
      availableDevices: availableDevices ?? this.availableDevices,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ??
          this.hasSearched,
    );
  }
}

class DeviceDiscoveryNotifier extends StateNotifier<DeviceDiscoveryState> {
  DeviceDiscoveryNotifier() : super(DeviceDiscoveryState());

  final ConfigService configService = ConfigService();
  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();

  Future<void> discoverDevices() async {
    state = state.copyWith(isLoading: true, hasSearched: true);
    try {
      final serviceType = await configService.get('service_discovery_type');
      final discoveredDevices = await mdnsDiscoveryService.startDiscovery(serviceType);

      discoveredDevices.map((device) => Device(
        deviceName: device.deviceName,
        deviceAddress: device.deviceAddress,
        devicePort: device.devicePort,
      )).toList();

      state = state.copyWith(availableDevices: discoveredDevices, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}


final deviceDiscoveryProvider =
    StateNotifierProvider<DeviceDiscoveryNotifier, DeviceDiscoveryState>((ref) {
  return DeviceDiscoveryNotifier();
});
