import 'dart:convert';
import 'dart:io';
import 'package:espressif_grinder_flutter/services/api_service.dart';
import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:espressif_grinder_flutter/services/mdns_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../models/device.dart';


String extractDeviceName(String input) {
  if (input.isEmpty) return input;
  final String name = input.split('.')[0];
  return name[0].toUpperCase() + name.substring(1);
}

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

      try {
        final Response deviceInfo = await _apiService.get(endpoint);

        if (deviceInfo.statusCode == 200) {
          availableDevices.add(Device(deviceName: device.deviceName, deviceAddress: address, devicePort: port));
        }
      } finally {}
    }

    return availableDevices;
  }

  Future<bool> checkDeviceInitialisationState(Device device) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/status";

    try {
      final Response response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if(data['authKey']){return true;}
      }
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

  Future<bool> pushCertificateToDevice(Device device, certificate, String type) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/$type";

    try {
      final responseOk = await _apiService.uploadFile(endpoint, certificate).timeout(const Duration(seconds: 5));

      if (responseOk) {
        // switching to TLS mode
        await init(useTLS: true);

        return true;
      } else {
        return false;
      }
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
      final response = await _apiService.post(endpoint, credentials);

      if (response.statusCode == 200) {
        return true;
      }
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


  Future<bool> waitForDeviceToBecomeReady(Device device, {int timeoutSeconds = 30}) async {
    final Duration timeoutDuration = Duration(seconds: timeoutSeconds);
    final DateTime endTime = DateTime.now().add(timeoutDuration);

    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/status";

    while (DateTime.now().isBefore(endTime)) {
      try {
        final response = await _apiService.get(endpoint).timeout(const Duration(seconds: 5)); // Set a reasonable timeout for the GET request itself

        if (response.statusCode == 200) {
          return true;
        }
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
      final Response registerInfo = await _apiService.get(endpoint);

      if (registerInfo.statusCode == 200) {
        final String data = registerInfo.body;
        _configService.set('token', data);
      } else {
        print("Failed to register with device");
      }
    } catch (e) {
      print("Error registering with device: $e");
    }

    return Future.value(true);
  }

  Future<bool> getDeviceDetails(Device device, String authKey) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/device/details";

    try {
      final Response deviceDetails = await _apiService.get(endpoint);

      if (deviceDetails.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(deviceDetails.body);

        device.deviceProductManufacturer = data['deviceProductManufacturer'];
        device.deviceProductName = data['deviceProductName'];
        device.deviceProductSerial = data['deviceProductSerial'];

      } else {
        print("Failed to get details from device");
      }
    } catch (e) {
      print("Error getting details from device: $e");
    }

    return Future.value(true);
  }

  Future<bool> finishInitAndResetDevice(Device device) async {
    final String address = device.deviceAddress;
    final int port = device.devicePort;
    final String baseUrl = "http://$address:$port";
    final String endpoint = "$baseUrl/api/init/finish";

    try {
      final Response response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if(data['authKey']){return true;}
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error finish and reset device: $e",
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

}
