import 'package:flutter/material.dart';

import 'bluetooth_devices_page.dart';
import 'chart_page.dart';
import 'dashboard_page.dart';
import 'terminal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 3;

  final List<Widget> pages = const [
    BluetoothDevicesPage(),
    TerminalPage(),
    ChartPage(),
    DashboardPage()
  ];

  final List<String> titles = const [
    'Bluetooth Cihazları',
    'Terminal',
    'BPM Grafiği',
    'Durum Paneli'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'SleepGuard',
                style: TextStyle(
                  fontWeight: FontWeight.w800
                )
              )
            )
          )
        ]
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bluetooth),
            selectedIcon: Icon(Icons.bluetooth_connected),
            label: 'Cihazlar'
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal),
            selectedIcon: Icon(Icons.code),
            label: 'Terminal'
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.analytics),
            label: 'Grafik'
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'Durum'
          )
        ]
      )
    );
  }
}
