import 'package:espressif_grinder_flutter/providers/device_provider.dart';
import 'package:espressif_grinder_flutter/services/cert_service.dart';
import 'package:espressif_grinder_flutter/services/setup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/device.dart';

class DeviceSetupState {
  final Device? selectedDevice;
  final String? errorMessage;
  final String statusMessage;
  final bool isLoading;
  final int currentSetupStep;
  final bool setupFinished;
  final bool setupIsRunning;
  final String authToken;
  String wifiAccessPoint;
  String wifiPassword;

  bool showPrevPageArrow;
  bool showNextPageArrow;
  bool showNavButton;
  String navButtonText;
  bool navButtonEnabled;
  String navRoute;

  DeviceSetupState(
      {this.selectedDevice,
      this.errorMessage = '',
      this.isLoading = false,
      this.setupIsRunning = false,
      this.setupFinished = false,
      this.currentSetupStep = 0,
      this.statusMessage = 'Initializing...',
      this.wifiAccessPoint = '',
      this.wifiPassword = '',
      this.authToken = '',
      this.showNextPageArrow = false,
      this.showPrevPageArrow = false,
      this.showNavButton = false,
      this.navButtonText = 'Start',
      this.navButtonEnabled = true,
      this.navRoute = '/welcome'});

  DeviceSetupState copyWith(
      {Device? selectedDevice,
      String? errorMessage,
      bool? isLoading,
      int? currentSetupStep,
      String? statusMessage,
      bool? setupFinished,
      bool? setupIsRunning,
      String? wifiAccessPoint,
      String? wifiPassword,
      String? authToken,
      bool? showNextPageArrow,
      bool? showPrevPageArrow,
      bool? showNavButton,
      String? navButtonText,
      bool? navButtonEnabled,
      String? navRoute}) {
    return DeviceSetupState(
        selectedDevice: selectedDevice ?? this.selectedDevice,
        errorMessage: errorMessage ?? this.errorMessage,
        isLoading: isLoading ?? this.isLoading,
        currentSetupStep: currentSetupStep ?? this.currentSetupStep,
        statusMessage: statusMessage ?? this.statusMessage,
        setupIsRunning: setupIsRunning ?? this.setupIsRunning,
        setupFinished: setupFinished ?? this.setupFinished,
        wifiAccessPoint: wifiAccessPoint ?? this.wifiAccessPoint,
        wifiPassword: wifiPassword ?? this.wifiPassword,
        authToken: authToken ?? this.authToken,
        showNextPageArrow: showNextPageArrow ?? this.showNextPageArrow,
        showPrevPageArrow: showPrevPageArrow ?? this.showPrevPageArrow,
        showNavButton: showNavButton ?? this.showNavButton,
        navButtonText: navButtonText ?? this.navButtonText,
        navButtonEnabled: navButtonEnabled ?? this.navButtonEnabled,
        navRoute: navRoute ?? this.navRoute);
  }
}

class DeviceSetupNotifier extends StateNotifier<DeviceSetupState> {
  final DeviceSetupService setupService = DeviceSetupService();
  final CertificateService certificateService = CertificateService();
  late final Device device;

  DeviceSetupNotifier(Device deviceState) : super(DeviceSetupState()) {
    device = deviceState;
  }

  Future<void> startDeviceSetup() async {
    await setupService.init(device: device);

    device.deviceName = 'CoffeeGrinder';
    device.deviceAddress = '192.168.4.1';
    device.devicePort = 80;

    state = state.copyWith(setupIsRunning: true, selectedDevice: device);

    List<Future<bool> Function()> setupSteps = [
      () => waitForDeviceToBecomeReady(),
      () => generateCertificates(),
      () => pushCertificatesToDevice(),
      () => pushWifiConfigToDevice(state.wifiAccessPoint, state.wifiPassword),
      () => registerWithDevice(),
      () => getDeviceInfo(),
      () => finishInitAndResetDevice(),
      () => waitForDeviceToBecomeReady()
    ];

    for (var i = 0; i < setupSteps.length; i++) {
      if (!state.setupIsRunning)
        break; // Check if the setup process was stopped
      var success = await setupSteps[i]();
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          setupIsRunning: false,
          errorMessage: state.errorMessage,
        );
        return;
      }
      state = state.copyWith(currentSetupStep: i + 1);
    }

    // Finalize setup
    state = state.copyWith(
      isLoading: false,
      setupIsRunning: false,
      setupFinished: true,
      statusMessage: "Setup complete",
    );
  }

  Future<void> stopDeviceSetup(String message) async {
    state = state.copyWith(
        errorMessage: message, isLoading: false, setupIsRunning: false);
    showToast(message);
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void updateStep(String message) {
    state = state.copyWith(
      currentSetupStep: state.currentSetupStep + 1,
      statusMessage: message,
    );
  }

  void updateWifiAccessPoint(String ssid) {
    state = state.copyWith(wifiAccessPoint: ssid);
    updateNavButtonEnabledState();
  }

  void updateWifiPassword(String password) {
    state = state.copyWith(wifiPassword: password);
    updateNavButtonEnabledState();
  }

  void updateNavButtonEnabledState() {
    // Enable the button only if both ssid and password are non-empty
    bool isButtonEnabled = state.wifiAccessPoint.isNotEmpty && state.wifiPassword.isNotEmpty;
    state = state.copyWith(navButtonEnabled: isButtonEnabled);
  }

  void setNextPageArrowVisibility(bool visible) {
    state = state.copyWith(showNextPageArrow: visible);
  }

  void setPrevPageArrowVisibility(bool visible) {
    state = state.copyWith(showPrevPageArrow: visible);
  }

  void setNavButtonVisibility(bool visible) {
    state = state.copyWith(showNavButton: visible);
  }

  void setNavButtonText(String text) {
    state = state.copyWith(navButtonText: text);
  }

  void setNavRoute(String text) {
    state = state.copyWith(navRoute: text);
  }

  Future<bool> checkDeviceInitialisationState() async {
    updateStep("Device not initialized");

    final isInitialized = await setupService.checkDeviceInitialisationState();
    if (!isInitialized) {
      stopDeviceSetup("Device already initialized");
    }
    return isInitialized;
  }

  Future<bool> generateCertificates() async {
    updateStep("Generating certificates...");

    final isGenerated = await certificateService.generateAndSaveCertificates();
    if (!isGenerated) {
      stopDeviceSetup("Could not generate certificates");
    }
    return isGenerated;
  }

  Future<bool> pushCertificatesToDevice() async {
    updateStep("Pushing certificates to device...");

    final isCertPushed =
        await setupService.pushCertificateToDevice('cert.der', 'cert');
    final isKeyPushed =
        await setupService.pushCertificateToDevice('key.der', 'key');

    if (!isCertPushed || !isKeyPushed) {
      stopDeviceSetup("Could not push certificates to device");
      return false;
    }
    return true;
  }

  Future<bool> pushWifiConfigToDevice(
      String accessPoint, String password) async {
    updateStep("Pushing WiFi credentials to device...");

    final isPushed =
        await setupService.pushWifiConfigToDevice(accessPoint, password);
    if (!isPushed) {
      stopDeviceSetup("Could not push Wifi credentials to device");
    }
    return isPushed;
  }

  Future<bool> waitForDeviceToBecomeReady() async {
    updateStep("Waiting for device to become ready...");

    final isReady = await setupService.waitForDeviceToBecomeReady();
    if (!isReady) {
      stopDeviceSetup("Device did not become ready in a reasonable time");
    }
    return isReady;
  }

  Future<bool> registerWithDevice() async {
    updateStep("Registering with device...");

    final isRegistered = await setupService.registerWithDevice();
    if (!isRegistered) {
      stopDeviceSetup("Could not register with device");
    }
    return isRegistered;
  }

  Future<bool> getDeviceInfo() async {
    updateStep("Getting device info...");

    final gotDetails = await setupService.registerWithDevice();
    if (!gotDetails) {
      stopDeviceSetup("Could not get device info");
    }
    return gotDetails;
  }

  Future<bool> finishInitAndResetDevice() async {
    updateStep("Finishing setup...");

    final isFinished = await setupService.finishInitAndResetDevice();
    if (!isFinished) {
      stopDeviceSetup("Could not finish setup");
    }
    return isFinished;
  }

  Future<bool> resetDeviceToFactorySettings() async {
    state = state.copyWith(
      errorMessage: '',
      isLoading: false,
      currentSetupStep: 0,
      setupIsRunning: false,
      setupFinished: false,
      statusMessage: 'Initializing...',
    );

    final isReset = await setupService.resetDeviceToFactorySettings();
    if (!isReset) {
      stopDeviceSetup("Could not reset device");
    }
    return isReset;
  }
}

final deviceSetupProvider =
    StateNotifierProvider<DeviceSetupNotifier, DeviceSetupState>((ref) {
  final device = ref.watch(deviceStateProvider);

  return DeviceSetupNotifier(device);
});
