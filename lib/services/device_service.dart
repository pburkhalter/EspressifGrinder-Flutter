import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:espressif_grinder_flutter/services/api_service.dart';
import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:espressif_grinder_flutter/services/mdns_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../models/device.dart';


class DeviceService {
  final MdnsServiceDiscovery _mdnsClient = MdnsServiceDiscovery();
  final ConfigService _configService = ConfigService();
  late final ApiService _apiService = ApiService();
  List<Device> availableDevices = [];

  DeviceService();

  Future<void> init({useTLS = false}) async {
      await _apiService.init(useTLS: useTLS);
  }

  Future<List<Device>> discoverDevices() async {
    List<Device> discoveredDevices = await _mdnsClient.startDiscovery(await _configService.get('service_discovery_type'));
    List<Device> availableDevices = [];

    for (Device device in discoveredDevices) {

      final String address = device.deviceAddress;
      final int port = device.devicePort;
      final String baseUrl = "http://$address:$port";
      final String endpoint = "$baseUrl/api/init/status";

      availableDevices.add(Device(deviceName: device.deviceName, deviceAddress: address, devicePort: port));

      try {
        final Response deviceInfo = await _apiService.get(endpoint);
      } finally {}
    }

    return availableDevices;
  }

  Future<String?> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }

  Future<bool> checkDeviceInitialisationState(Device device) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/status";

    try {
      // OK
      final String response = await _apiService.get(endpoint);
      return true;

    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error checking device initialisation status: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return false;
  }

  Future<bool> pushCertificateToDevice(Device device, certificateName, String type) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/$type";

    try {
      final response = await _apiService.uploadFile(endpoint, certificateName).timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pushWifiConfigToDevice(Device device, String accesspoint, String password) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/wifi";

    final Map<String, dynamic> credentials = {
      "ssid": accesspoint,
      "password": password
    };

    try {
      // OK
      final String response = await _apiService.post(endpoint, credentials);
      return true;

    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error pushing WiFi credentials: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return false;
  }


  Future<bool> waitForDeviceToBecomeReady(Device device, {int timeoutSeconds = 60}) async {
    final Duration timeoutDuration = Duration(seconds: timeoutSeconds);
    final DateTime endTime = DateTime.now().add(timeoutDuration);

    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/status";

    while (DateTime.now().isBefore(endTime)) {
      try {
        // OK
        final String response = await _apiService.get(endpoint).timeout(const Duration(seconds: 5));
        return true;
      } catch (e) {
        // retry...
      }
      // Wait for a bit before trying again
      await Future.delayed(const Duration(seconds: 5));
    }
    // If we reach this point, the device did not become ready within the time limit
    return false;
  }

  Future<bool> registerWithDevice(Device device) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/register";

    try {
      // TODO save token!
      String? id = await getDeviceId();

      final String token = await _apiService.post(endpoint, id);
      return true;
    } catch (e) {
      print("Error registering with device: $e");
    }
    return false;
  }

  Future<bool> getDeviceDetails(Device device, String authKey) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/device/details";

    try {
      // JSON
      final Map<String, dynamic> deviceDetails = await _apiService.get(endpoint);

      device.deviceProductManufacturer = deviceDetails['deviceProductManufacturer'];
      device.deviceProductName = deviceDetails['deviceProductName'];
      device.deviceProductSerial = deviceDetails['deviceProductSerial'];

      return true;
    } catch (e) {
      print("Error getting details from device: $e");
    }
    return false;
  }

  Future<bool> finishInitAndResetDevice(Device device) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/finish";

    try {
      final String response = await _apiService.get(endpoint);
      return true;
    } catch (e) {
      print("Error finishing setup: $e");
    }
    return false;
  }
}
