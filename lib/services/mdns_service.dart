import 'dart:async';
import 'package:flutter_nsd/flutter_nsd.dart';

import '../models/device.dart';
import '../utils/logger.dart';

class MdnsService {
  final FlutterNsd _flutterNsd = FlutterNsd();
  final List<Device> _devices = [];
  late StreamSubscription<NsdServiceInfo> _nsdSubscription;

  Future<List<Device>> discoverDevices(String serviceType) async {
    _devices.clear(); // Clear any previously discovered devices

    _nsdSubscription = _flutterNsd.stream.listen(
          (nsdServiceInfo) {
        print('Discovered service name: ${nsdServiceInfo.name}');
        print('Discovered service hostname/IP: ${nsdServiceInfo.hostname}');
        print('Discovered service port: ${nsdServiceInfo.port}');

        // Add discovered service to devices list
        _devices.add(Device(
          deviceName: nsdServiceInfo.name ?? 'Unknown',
          deviceAddress: nsdServiceInfo.hostname ?? 'Unknown',
          devicePort: nsdServiceInfo.port ?? 80,
        ));
      },
      onError: (e) {
        if (e is NsdError) {
          logger.e('NSD Error: ${e.errorCode}');
        }
      },
    );

    await _flutterNsd.discoverServices(serviceType);

    // Wait for a specified duration for devices to be discovered
    await Future.delayed(const Duration(seconds: 120));
    await stopDiscovery();

    return _devices;
  }

  Future<void> stopDiscovery() async {
    await _nsdSubscription.cancel();
    await _flutterNsd.stopDiscovery();
  }
}
