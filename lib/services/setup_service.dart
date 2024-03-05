import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:espressif_grinder_flutter/services/api_service.dart';
import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:espressif_grinder_flutter/services/mdns_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device.dart';
import '../utils/logger.dart';


class DeviceSetupService {
  final _configService = ConfigService();
  final ApiService _apiService = ApiService();
  final MdnsService _mdnsService = MdnsService();
  late final Device _device;
  late final SharedPreferences _prefs;


  Future<void> init({
    bool useTLS = false, required Device device}) async {
    _device = device;
    _prefs = await SharedPreferences.getInstance();

    await _apiService.init(useTLS: useTLS);
  }

  String? getDeviceBaseUrl({bool https = false}) {
    if (_device.deviceAddress == null || _device.devicePort == null) {
      logger.e("Device address or port is null");
      return null;
    }
    String prefix;
    if(https){prefix = 'https';}
    else{prefix = 'http';}

    return "$prefix://${_device.deviceAddress}:${_device.devicePort}";
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
    String? baseUrl = getDeviceBaseUrl(https: _apiService.useTLS);
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
      await _apiService.get(endpoint);
    });
  }

  Future<bool> pushCertificateToDevice(String certificateName, String type) async {
    return await makeRequest("/api/init/$type", (endpoint) async {
      await _apiService.uploadCert(endpoint, certificateName);
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
      var success = await makeRequest("/api/status", (endpoint) async {
        await _apiService.get(endpoint).timeout(const Duration(seconds: 5));
      });
      if (success) return true;
      await Future.delayed(const Duration(seconds: 5));
    }
    logger.e("Device did not become ready in time");
    return false;
  }

  Future<bool> registerWithDevice() async {
    var clientId = await getClientId();
    if (clientId == null) {return false;}
    return await makeRequest("/api/init/register", (endpoint) async {
      String token = await _apiService.post(endpoint, clientId);
      _prefs.setString("token", token);
    });
  }

  Future<Device?> getDeviceDetails() async {
    await makeRequest("/api/init/device", (endpoint) async {
      var deviceDetails = await _apiService.get(endpoint);
      _device.deviceProductManufacturer = deviceDetails['deviceProductManufacturer'];
      _device.deviceProductName = deviceDetails['deviceProductName'];
      _device.deviceProductSerial = deviceDetails['deviceProductSerial'];
      return _device;
    });
    return null;
  }

  Future<bool> finishInitAndResetDevice() async {
    var success = await makeRequest("/api/init/finish", (endpoint) async {
      await _apiService.get(endpoint);
    });
    if(success){
      // device will restart with TLS enabled, so we'll switch to TLS too
      await _apiService.init(useTLS: true);

      _device.deviceName = 'CoffeeGrinder';
      _device.deviceAddress = 'coffeegrinder.local';
      _device.devicePort = 443;

      return true;
    }
    return false;
  }

  Future<bool> resetDeviceToFactorySettings() async {
    // device will restart without TLS enabled, so we'll switch too...
    await _apiService.init(useTLS: false);

    _device.deviceName = 'CoffeeGrinder';
    _device.deviceAddress = '192.168.4.1';
    _device.devicePort = 80;

    var success = await makeRequest("/api/reset", (endpoint) async {
      await _apiService.get(endpoint);
    });

    return success;
  }

  Future<Device?> discoverDevice() async {
    List<Device>? discoveredDevices = await _mdnsService.discoverDevices(
        await _configService.get('service_discovery_type'));

    if(discoveredDevices.isNotEmpty){
      for (Device device in discoveredDevices) {
        final String? address = device.deviceAddress;
        final int? port = device.devicePort;
        final String baseUrl = "https://$address:$port";
        final String endpoint = "$baseUrl/api/config";

        try {
          var success = await _apiService.get(endpoint);
          if(success){
            _device.deviceName = device.deviceName;
            _device.devicePort = device.devicePort;
            _device.deviceAddress = device.deviceAddress;
            return _device;
          }
        } catch (error) {
          print(error.toString());
          logger.e("Error making request to $endpoint: $error");
        }
      }
    }
    return null;
  }
}


