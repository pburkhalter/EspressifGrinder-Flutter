import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../services/device_service.dart';


class DeviceDiscoveryState {
  final List<Device> availableDevices;
  final String? errorMessage;
  final bool isLoading;
  final bool hasSearched; // New flag to track if a search has been performed

  DeviceDiscoveryState({
    this.availableDevices = const [],
    this.errorMessage,
    this.isLoading = false,
    this.hasSearched = false, // Initialize as false
  });

  DeviceDiscoveryState copyWith({
    List<Device>? availableDevices,
    String? errorMessage,
    bool? isLoading,
    bool? hasSearched, // Include in copyWith method
  }) {
    return DeviceDiscoveryState(
      availableDevices: availableDevices ?? this.availableDevices,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched, // Update with new value or retain old
    );
  }
}



class DeviceDiscoveryNotifier extends StateNotifier<DeviceDiscoveryState> {
  DeviceDiscoveryNotifier() : super(DeviceDiscoveryState());

  late final DeviceService _deviceService = DeviceService();

  Future<void> discoverDevices() async {
    await _deviceService.init();

    state = state.copyWith(isLoading: true, hasSearched: true); // Set hasSearched to true as search begins
    try {
      final devices = await _deviceService.discoverDevices();
      state = state.copyWith(availableDevices: devices, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

}

final deviceDiscoveryProvider = StateNotifierProvider<DeviceDiscoveryNotifier, DeviceDiscoveryState>((ref) {
  return DeviceDiscoveryNotifier();
});

