import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:espressif_grinder_flutter/services/api_service.dart';
import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import '../utils/logger.dart';


class DeviceSetupService {
  final ApiService _apiService = ApiService();
  late final Device _device;
  late final SharedPreferences _prefs;


  Future<void> init({
    bool useTLS = false, required Device device}) async {
    _device = device;
    _prefs = await SharedPreferences.getInstance();

    await _apiService.init(useTLS: useTLS);
  }

  String? getBaseUrl() {
    if (_device.deviceAddress == null || _device.devicePort == null) {
      logger.e("Device address or port is null");
      return null;
    }
    return "http://${_device.deviceAddress}:${_device.devicePort}";
  }

  Future<String?> getClientId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    }
    return null;
  }

  Future<bool> makeRequest(String endpointSuffix, Function(String endpoint) apiCall) async {
    String? baseUrl = getBaseUrl();
    String fullEndpoint = "$baseUrl$endpointSuffix";
    try {
      await apiCall(fullEndpoint);
      return true;
    } catch (error) {
      logger.e("Error making request to $fullEndpoint: $error");
      return false;
    }
  }

  Future<bool> checkDeviceInitialisationState() async {
    return await makeRequest("/api/init/status", (endpoint) async {
      await _apiService.get(endpoint); // Assuming _apiService.get returns a Future<String>
    });
  }

  Future<bool> pushCertificateToDevice(String certificateName, String type) async {
    return await makeRequest("/api/init/$type", (endpoint) async {
      await _apiService.uploadFile(endpoint, certificateName);
    });
  }

  Future<bool> pushWifiConfigToDevice(String ssid, String password) async {
    var credentials = {"ssid": ssid, "password": password};
    return await makeRequest("/api/init/wifi", (endpoint) async {
      await _apiService.post(endpoint, credentials);
    });
  }

  Future<bool> waitForDeviceToBecomeReady({int timeoutSeconds = 60}) async {
    var endTime = DateTime.now().add(Duration(seconds: timeoutSeconds));
    while (DateTime.now().isBefore(endTime)) {
      var success = await makeRequest("/api/init/status", (endpoint) async {
        await _apiService.get(endpoint).timeout(Duration(seconds: 5));
      });
      if (success) return true;
      await Future.delayed(const Duration(seconds: 5));
    }
    logger.e("Device did not become ready in time");
    return false;
  }

  Future<bool> registerWithDevice() async {
    var clientId = await getClientId();
    if (clientId == null) {
      return false;
    }
    return await makeRequest("/api/init/register", (endpoint) async {
      String token = await _apiService.post(endpoint, clientId);
      _prefs.setString("token", token);
    });
  }

  Future<bool> getDeviceDetails() async {
    return await makeRequest("/api/init/device", (endpoint) async {
      var deviceDetails = await _apiService.get(endpoint);
      _device.deviceProductManufacturer = deviceDetails['deviceProductManufacturer'];
      _device.deviceProductName = deviceDetails['deviceProductName'];
      _device.deviceProductSerial = deviceDetails['deviceProductSerial'];
    });
  }

  Future<bool> finishInitAndResetDevice() async {
    return await makeRequest("/api/init/finish", (endpoint) async {
      await _apiService.get(endpoint);
    });
  }

}
