import 'dart:async';
import 'package:flutter_nsd/flutter_nsd.dart';
import '../models/device.dart';

String extractDeviceName(String input) {
  if (input.isEmpty) return input;
  final String name = input.split('.')[0];
  return name[0].toUpperCase() + name.substring(1);
}

class MdnsDiscoveryService {
  final flutterNsd = FlutterNsd();

  Future<List<Device>> startDiscovery(String serviceType) async {
    List<Device> devices = [];
    var completer = Completer<List<Device>>();

    final subscription = flutterNsd.stream.listen((nsdServiceInfo) {
      print('Discovered service name: ${nsdServiceInfo.name}');
      print('Discovered service hostname/IP: ${nsdServiceInfo.hostname}');
      print('Discovered service port: ${nsdServiceInfo.port}');

      final String deviceName = nsdServiceInfo.name ?? 'Unknown';
      final String deviceAddress =
          nsdServiceInfo.hostAddresses?.first ?? 'Unknown';
      final int devicePort = nsdServiceInfo.port ?? 0;

      final device = Device(
        deviceName: deviceName,
        deviceAddress: deviceAddress,
        devicePort: devicePort,
      );
      devices.add(device);
    }, onError: (e) {
      if (e is NsdError) {
        print("Error discovering services: ${e.errorCode}");
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    await flutterNsd.discoverServices(serviceType);

    Future.delayed(Duration(seconds: 10), () {
      flutterNsd.stopDiscovery();
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(devices);
      }
    });

    return completer.future;
  }
}
