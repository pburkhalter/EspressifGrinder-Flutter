import 'package:flutter/material.dart';
import '../../models/device.dart';

class DeviceListView extends StatelessWidget {
  final List<Device> devices;
  final Function(Device) onDeviceTap;

  const DeviceListView({
    Key? key,
    required this.devices,
    required this.onDeviceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.separated(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Material(
            color: Colors.transparent, // Use transparent color for the Material widget
            child: InkWell(
              onTap: () => onDeviceTap(device),
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Apply color here inside Ink
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text("Test Device"),  // TODO
                  subtitle: Text('Address: ${device.deviceAddress}, Port: ${device.devicePort}'),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 5),
      ),
    );
  }
}
