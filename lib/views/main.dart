import 'package:espressif_grinder_flutter/views/device.dart';
import 'package:espressif_grinder_flutter/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);


class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);

    List<Widget> pages = const [
      DevicePage(),
      SettingsPage()
    ];

    return Scaffold(
      body: pages[tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFEFAFE),
        elevation: 0,
        currentIndex: tabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Device'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
