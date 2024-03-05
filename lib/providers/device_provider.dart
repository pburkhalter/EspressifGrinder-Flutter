import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';

class DeviceNotifier extends StateNotifier<Device> {
  DeviceNotifier() : super(Device());

  void updateDeviceDetails({
    String? deviceName,
    String? deviceAddress,
    int? devicePort,
    String? deviceAuthKey,
    bool? deviceInitializedState,
    DateTime? deviceInitializedDate,
    String? deviceProductName,
    String? deviceProductManufacturer,
    String? deviceProductSerial,
    String? grindMode,
    int? singleGrindsDone,
    int? doubleGrindsDone,
    int? singleGrindDuration,
    int? doubleGrindDuration,
  }) {
    state = Device(
      deviceName: deviceName ?? state.deviceName,
      deviceAddress: deviceAddress ?? state.deviceAddress,
      devicePort: devicePort ?? state.devicePort,
    )
      ..deviceAuthKey = deviceAuthKey ?? state.deviceAuthKey
      ..deviceInitializedState = deviceInitializedState ?? state.deviceInitializedState
      ..deviceInitializedDate = deviceInitializedDate ?? state.deviceInitializedDate
      ..deviceProductName = deviceProductName ?? state.deviceProductName
      ..deviceProductManufacturer = deviceProductManufacturer ?? state.deviceProductManufacturer
      ..deviceProductSerial = deviceProductSerial ?? state.deviceProductSerial
      ..grindMode = grindMode ?? state.grindMode
      ..singleGrindsDone = singleGrindsDone ?? state.singleGrindsDone
      ..doubleGrindsDone = doubleGrindsDone ?? state.doubleGrindsDone
      ..singleGrindDuration = singleGrindDuration ?? state.singleGrindDuration
      ..doubleGrindDuration = doubleGrindDuration ?? state.doubleGrindDuration;
  }
}

final deviceStateProvider = StateNotifierProvider<DeviceNotifier, Device>((ref) {

  return DeviceNotifier();
});



