import 'dart:io';

import 'package:espressif_grinder_flutter/services/cert_service.dart';
import 'package:espressif_grinder_flutter/services/device_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';


class DeviceSetupState {
  final Device? selectedDevice;
  final String? errorMessage;
  final bool isLoading;
  final int processStep;
  final String statusMessage;
  final String wifiAccessPoint;
  final String wifiPassword;


  DeviceSetupState({
    this.selectedDevice,
    this.errorMessage = '',
    this.isLoading = false,
    this.processStep = 0,
    this.statusMessage = 'Waiting...',

    this.wifiAccessPoint = '',
    this.wifiPassword = '',
  });

  DeviceSetupState copyWith({
    Device? selectedDevice,
    String? errorMessage,
    bool? isLoading,
    int? processStep,
    String? statusMessage,
    String? wifiAccessPoint,
    String? wifiPassword
  }) {
    return DeviceSetupState(
      selectedDevice: selectedDevice ?? this.selectedDevice,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      processStep: processStep ?? this.processStep,
      statusMessage: statusMessage ?? this.statusMessage,

      wifiAccessPoint: wifiAccessPoint ?? this.wifiAccessPoint,
      wifiPassword: wifiPassword ?? this.wifiPassword
    );
  }
}


class DeviceSelectedNotifier extends StateNotifier<DeviceSetupState> {
  DeviceSelectedNotifier() : super(DeviceSetupState());

  void selectDevice(Device device) {
    state = state.copyWith(selectedDevice: device);
  }
}


class DeviceSetupNotifier extends StateNotifier<DeviceSetupState> {
  DeviceSetupNotifier() : super(DeviceSetupState());
  DeviceService deviceService = DeviceService();
  CertificateService certificateService = CertificateService();


  Future<void> setupDevice(Device device) async {
    if (state.processStep == 0 && state.errorMessage!.isEmpty) {
      await checkDeviceInitialisationState(device);
    }
    if(state.processStep == 1 && state.errorMessage!.isEmpty){
      await generateCertificates(device);
    }
    if(state.processStep == 2 && state.errorMessage!.isEmpty){
      await pushCertificatesToDevice(device);
    }
    if(state.processStep == 3 && state.errorMessage!.isEmpty){
      var ap = state.wifiAccessPoint;
      var pw = state.wifiPassword;

      await pushWifiConfigToDevice(device, ap, pw);
    }
    if(state.processStep == 4 && state.errorMessage!.isEmpty){
      await waitForDeviceToBecomeReady(device);
    }
    if(state.processStep == 5 && state.errorMessage!.isEmpty){
      await registerWithDevice(device);
    }
    if(state.processStep == 6 && state.errorMessage!.isEmpty){
      await finishInitAndResetDevice(device);
    }

  }


  void updateWifiAccessPoint(String ssid) {
    state = state.copyWith(wifiAccessPoint: ssid);
  }

  void updateWifiPassword(String password) {
    state = state.copyWith(wifiPassword: password);
  }


  Future<bool> checkDeviceInitialisationState(Device device) async {
    final isInitialized = await deviceService.checkDeviceInitialisationState(device);
    if (isInitialized) {
      state = state.copyWith(
        processStep: 1,
        statusMessage: "Device initialized...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not initialize device...",);
    return false;
  }

  Future<bool> generateCertificates(Device device) async {
    final isGenerated = await certificateService.generateAndSaveCertificates();
    if (isGenerated) {
      state = state.copyWith(
        processStep: 2,
        statusMessage: "Certificates generated...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not generate certificates...",);
    return false;
  }

  Future<bool> pushCertificatesToDevice(Device device) async {
    final List<int> certDer = await certificateService.loadCertDer();
    final List<int> keyDer = await certificateService.loadKeyDer();

    final isCertPushed = await deviceService.pushCertificateToDevice(device, certDer, 'cert');
    final isKeyPushed = await deviceService.pushCertificateToDevice(device, keyDer, 'key');

    if (isCertPushed && isKeyPushed) {
      state = state.copyWith(
        processStep: 3,
        statusMessage: "Certificates Pushed...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not push certificates to device...",);
    return false;
  }

  Future<bool> pushWifiConfigToDevice(Device device, String accesspoint, String password) async {
    final isPushed = await deviceService.pushWifiConfigToDevice(device, accesspoint, password);
    if (isPushed) {
      state = state.copyWith(
        processStep: 4,
        statusMessage: "Wifi-Config Pushed...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not push wifi credentials to device...",);
    return false;
  }

  Future<bool> waitForDeviceToBecomeReady(Device device) async {
    final isReady = await deviceService.waitForDeviceToBecomeReady(device);
    if (isReady) {
      state = state.copyWith(
        processStep: 5,
        statusMessage: "Device rebooted...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Device did not become ready within a reasonable time...",);
    return false;
  }

  Future<bool> registerWithDevice(Device device) async {
    final isRegistered = await deviceService.registerWithDevice(device);
    if (isRegistered) {
      state = state.copyWith(
        processStep: 6,
        statusMessage: "Client registered...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not register with device...",);
    return false;
  }

  Future<bool> finishInitAndResetDevice(Device device) async {
    final isFinished = await deviceService.finishInitAndResetDevice(device);
    if (isFinished) {
      state = state.copyWith(
        processStep: 7,
        statusMessage: "Finishing setup...",
      );
      return true;
    }
    state = state.copyWith(errorMessage: "Could not finish setup...",);
    return false;
  }

}


final deviceSelectedProvider = StateNotifierProvider<DeviceSelectedNotifier, DeviceSetupState>((ref) {
  return DeviceSelectedNotifier();
});


final deviceSetupProvider = StateNotifierProvider<DeviceSetupNotifier, DeviceSetupState>((ref) {
  return DeviceSetupNotifier();
});
