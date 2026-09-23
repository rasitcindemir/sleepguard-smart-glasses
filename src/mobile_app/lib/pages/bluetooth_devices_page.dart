import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class BluetoothDevicesPage extends StatelessWidget {
  const BluetoothDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BluetoothProvider>();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    provider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                    color: provider.isConnected ? Colors.green : Colors.blue,
                    size: 32
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      provider.statusMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600
                      )
                    )
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : () => provider.loadPairedDevices(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Eşleşmiş Cihazlar')
                )
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isDiscovering
                      ? () => provider.stopDiscovery()
                      : () => provider.startDiscovery(),
                  icon: Icon(provider.isDiscovering ? Icons.stop : Icons.search),
                  label: Text(provider.isDiscovering ? 'Durdur' : 'Ara')
                )
              )
            ]
          ),
          const SizedBox(height: 12),
          if (!provider.isBluetoothEnabled)
            ElevatedButton.icon(
              onPressed: provider.enableBluetooth,
              icon: const Icon(Icons.bluetooth),
              label: const Text('Bluetooth’u Aç')
            ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                const _SectionTitle(title: 'Eşleşmiş Cihazlar'),
                if (provider.pairedDevices.isEmpty)
                  const _EmptyText(
                    text: 'Eşleşmiş cihaz yok. Telefonun Bluetooth ayarlarından önce HC-05 ile eşleş.'
                  ),
                ...provider.pairedDevices.map((device) => _DeviceTile(device: device)),
                
                const SizedBox(height: 18),
                const _SectionTitle(title: 'Bulunan Cihazlar'),
                if (provider.discoveredDevices.isEmpty)
                  const _EmptyText(text: 'Henüz cihaz bulunmadı.'),
                ...provider.discoveredDevices.map((device) => _DeviceTile(device: device))
              ]
            )
          )
        ]
      )
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BluetoothProvider>();
    final isThisConnected = provider.connectedDeviceAddress == device.address;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          isThisConnected ? Icons.bluetooth_connected : Icons.devices,
          color: isThisConnected ? Colors.green : Colors.blue
        ),
        title: Text(
          device.name.isEmpty ? 'İsimsiz Cihaz' : device.name,
          style: const TextStyle(fontWeight: FontWeight.w800)
        ),
        subtitle: Text(device.address),
        trailing: isThisConnected
            ? ElevatedButton(
                onPressed: provider.disconnect,
                child: const Text('Kes')
              )
            : ElevatedButton(
                onPressed: provider.isLoading ? null : () => provider.connectToDevice(device),
                child: const Text('Bağlan')
              )
      )
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900
        )
      )
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(text)
      )
    );
  }
}
