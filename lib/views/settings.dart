import 'package:espressif_grinder_flutter/services/api_service.dart';
import 'package:espressif_grinder_flutter/services/config_service.dart';
import 'package:espressif_grinder_flutter/services/setup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _debugMode = false; // keep track of the debug mode toggle state.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFAFE),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFEFAFE),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
          children: [
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.restore,
              color: Colors.blue,
              text: 'Reset Device',
              onTap: () => _showConfirmationDialog(context, 'Reset Device'),
            ),
            _buildSettingsOption(
              context,
              icon: Icons.delete_forever,
              color: Colors.red,
              text: 'Forget Device',
              onTap: () => _showConfirmationDialog(context, 'Forget Device'),
            ),
            _buildSettingsOption(
              context,
              icon: Icons.search,
              color: Colors.blue,
              text: 'Search Devices',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchDevicesPage()));
              },
            ),
            const SizedBox(height: 32),

            SwitchListTile(
              value: _debugMode,
              onChanged: (value) {
                setState(() {
                  _debugMode = value;
                });
              },
              secondary: const Icon(Icons.code, color: Colors.green),
              title: const Text('Debug Mode'),
            ),
            _buildSettingsOption(
              context,
              icon: Icons.exit_to_app,
              color: Colors.blue,
              text: 'Reset App',
              onTap: () => _showConfirmationDialog(context, 'Reset App'),
            ),
            const SizedBox(height: 30),
            const Text(
                "EspressifGrinder V0.1.3",
                textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String text,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }

  void _showConfirmationDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (action == 'Reset Device') {
                  resetDevice();
                } else if (action == 'Forget Device') {
                  forgetDevice();
                } else if (action == 'Reset App') {
                  resetApp(context);
                }
                // Handle the action, such as resetting the device
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void resetDevice() {
  var setupService = DeviceSetupService();
  setupService.resetDeviceToFactorySettings();
  print('Device has been reset.');
}

void forgetDevice() {
  print('Device has been forgotten.');
}

void resetApp(context) {
  var configService = ConfigService();
  configService.set('firstrun_done', false);
  GoRouter.of(context).go("/firstrun/welcome");
}

class SearchDevicesPage extends StatelessWidget {
  const SearchDevicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Devices"),
      ),
      body: Center(
        child: const Text("Search Devices Page Content Here"),
      ),
    );
  }
}
