import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';


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
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class DeviceDiscoveryNotifier extends StateNotifier<DeviceDiscoveryState> {
  DeviceDiscoveryNotifier() : super(DeviceDiscoveryState());

  Future<bool> discoverDevices() async {
    // TODO
    return true;
  }
}


final deviceDiscoveryProvider = StateNotifierProvider<DeviceDiscoveryNotifier, DeviceDiscoveryState>((ref) {

  return DeviceDiscoveryNotifier();
});
