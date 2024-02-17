import 'package:multicast_dns/multicast_dns.dart';
import '../models/device.dart';

String extractDeviceName(String input) {
  if (input.isEmpty) return input;
  final String name = input.split('.')[0];
  return name[0].toUpperCase() + name.substring(1);
}

class MdnsServiceDiscovery {
  final MDnsClient _client = MDnsClient();

  Future<List<Device>> startDiscovery(String serviceType) async {
    List<Device> devices = [];

    await _client.start();
    await for (PtrResourceRecord ptr in _client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceType))) {

      final String fullName = ptr.domainName;
      final String name = extractDeviceName(fullName);

      await for (SrvResourceRecord srv in _client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(fullName))) {
        final device = Device(deviceName: name, deviceAddress: srv.target, devicePort: srv.port);
        devices.add(device);
      }
    }
    _client.stop();
    return devices;
  }
}
