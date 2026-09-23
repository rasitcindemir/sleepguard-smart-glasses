import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/bluetooth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SleepGuardApp());
}

class SleepGuardApp extends StatelessWidget {
  const SleepGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BluetoothProvider>(
      create: (_) {
        final provider = BluetoothProvider();
        provider.initialize();
        return provider;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SleepGuard',
        theme: ThemeData.dark(), // Replaced custom AppTheme for standalone compatibility
        home: const HomePage()
      )
    );
  }
}
