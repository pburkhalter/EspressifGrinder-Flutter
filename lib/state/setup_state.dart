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
  final bool setupFinished;
  final String authToken;


  DeviceSetupState({
    this.selectedDevice,
    this.errorMessage = '',
    this.isLoading = false,
    this.setupFinished = false,
    this.processStep = 0,
    this.statusMessage = 'Initializing...',

    this.wifiAccessPoint = '',
    this.wifiPassword = '',

    this.authToken = ''
  });

  DeviceSetupState copyWith({
    Device? selectedDevice,
    String? errorMessage,
    bool? isLoading,
    int? processStep,
    String? statusMessage,
    bool? setupFinished,
    String? wifiAccessPoint,
    String? wifiPassword,
    String? authToken
  }) {
    return DeviceSetupState(
        selectedDevice: selectedDevice ?? this.selectedDevice,
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading,
        processStep: processStep ?? this.processStep,
        statusMessage: statusMessage ?? this.statusMessage,
        setupFinished: setupFinished ?? this.setupFinished,

        wifiAccessPoint: wifiAccessPoint ?? this.wifiAccessPoint,
        wifiPassword: wifiPassword ?? this.wifiPassword,

        authToken: authToken ?? this.authToken
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


  Future<void> setupDevice() async {

    await deviceService.init();

    Device device = Device(
        deviceName: 'CoffeeGrinder',
        deviceAddress: '192.168.4.1',
        devicePort: 80
    );

    state = state.copyWith(selectedDevice: device);

    if (state.processStep == 0 && (state.errorMessage?.isEmpty ?? true)) {
      state = state.copyWith(
          processStep: 1,
          statusMessage: "Waiting for device to become ready..."
      );
      var success = await waitForDeviceToBecomeReady(device);
      if (!success) { state = state.copyWith(errorMessage: "Device did not become ready in a reasonable time"); }
    }
    if(state.processStep == 1 && (state.errorMessage?.isEmpty ?? true)){
      state = state.copyWith(
          processStep: 2,
          statusMessage: "Generating certificates..."
      );
      var success = await generateCertificates(device);
      if (!success) { state = state.copyWith(errorMessage: "Could not generate certificates"); }
    }
    if(state.processStep == 2 && (state.errorMessage?.isEmpty ?? true)){
      state = state.copyWith(
          processStep: 3,
          statusMessage: "Pushing certificates to device..."
      );
      var success = await pushCertificatesToDevice(device);
      if (!success) { state = state.copyWith(errorMessage: "Could not push certificates to device"); }
    }
    if(state.processStep == 3 && (state.errorMessage?.isEmpty ?? true)){
      var ap = state.wifiAccessPoint;
      var pw = state.wifiPassword;

      state = state.copyWith(statusMessage: "Pushing WiFi Credentials to device...");
      state = state.copyWith(
          processStep: 4,
          statusMessage: "Pushing wifi credentials to device..."
      );
      var success = await pushWifiConfigToDevice(device, ap, pw);
      if (!success) { state = state.copyWith(errorMessage: "Could not push Wifi credentials to device"); }
    }
    if(state.processStep == 4 && (state.errorMessage?.isEmpty ?? true)){
      state = state.copyWith(
          processStep: 5,
          statusMessage: "Register with device..."
      );
      var success = await registerWithDevice(device);
      if (!success) { state = state.copyWith(errorMessage: "Could not register with device"); }
    }
    if(state.processStep == 5 && (state.errorMessage?.isEmpty ?? true)){
      state = state.copyWith(
          processStep: 6,
          statusMessage: "Getting device info..."
      );
      var success = await getDeviceInfo(device);
      if (!success) { state = state.copyWith(errorMessage: "Could not get device info"); }
    }
    if(state.processStep == 6 && (state.errorMessage?.isEmpty ?? true)){
      state = state.copyWith(
          processStep: 7,
          statusMessage: "Finish setup..."
      );
      var success = await finishInitAndResetDevice(device);
      if (success) { state = state.copyWith(
          isLoading: false,
          setupFinished: true); }
      else {
          state = state.copyWith(errorMessage: "Could not finish setup");
      }
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
    if (isInitialized) {return true;}
    else {return false;}
  }

  Future<bool> generateCertificates(Device device) async {
    final isGenerated = await certificateService.generateAndSaveCertificates();
    if (isGenerated) {return true;}
    else {return false;}
  }

  Future<bool> pushCertificatesToDevice(Device device) async {
    final isCertPushed = await deviceService.pushCertificateToDevice(device, 'cert.der', 'cert');
    final isKeyPushed = await deviceService.pushCertificateToDevice(device, 'key.der', 'key');

    if (isCertPushed && isKeyPushed) {return true;}
    else {return false;}
  }

  Future<bool> pushWifiConfigToDevice(Device device, String accesspoint, String password) async {
    final isPushed = await deviceService.pushWifiConfigToDevice(device, accesspoint, password);
    if (isPushed) {return true;}
    else {return false;}
  }

  Future<bool> waitForDeviceToBecomeReady(Device device) async {
    final isReady = await deviceService.waitForDeviceToBecomeReady(device);
    if (isReady) {return true;}
    else {return false;}
  }

  Future<bool> registerWithDevice(Device device) async {
    final isRegistered = await deviceService.registerWithDevice(device);
    if (isRegistered) {return true;}
    else {return false;}
  }

  Future<bool> getDeviceInfo(Device device) async {
    final details = await deviceService.registerWithDevice(device);
    if (details) {return true;}
    else {return false;}
  }

  Future<bool> finishInitAndResetDevice(Device device) async {
    final isFinished = await deviceService.finishInitAndResetDevice(device);
    if (isFinished) {return true;}
    else {return false;}
  }
}


final deviceSelectedProvider = StateNotifierProvider<DeviceSelectedNotifier, DeviceSetupState>((ref) {
  return DeviceSelectedNotifier();
});


final deviceSetupProvider = StateNotifierProvider<DeviceSetupNotifier, DeviceSetupState>((ref) {
  return DeviceSetupNotifier();
});
