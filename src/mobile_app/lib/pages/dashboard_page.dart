import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';
import '../widgets/status_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Color _riskColor(String risk) {
    if (risk == 'Yüksek Risk') return Colors.red;
    if (risk == 'Uyku Riski') return Colors.orange;
    if (risk == 'Sensör Teması Yok') return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BluetoothProvider>();
    final data = provider.latestData;
    final risk = data?.riskStatus ?? 'Veri Bekleniyor';
    final riskColor = data == null ? Colors.grey : _riskColor(risk);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10233A), Color(0xFF07111F)]
              ),
              border: Border.all(color: Colors.blue, width: 0.5)
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SleepGuard',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)
                ),
                SizedBox(height: 8),
                Text(
                  'Akıllı Uyku Önleyici Gözlük Takip Sistemi',
                  style: TextStyle(color: Colors.grey, fontSize: 15)
                )
              ]
            )
          ),
          const SizedBox(height: 18),
          StatusCard(
            title: 'Bağlantı Durumu',
            value: provider.isConnected ? '${provider.connectedDeviceName ?? 'HC-05'} bağlı' : 'Bağlı değil',
            icon: provider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: provider.isConnected ? Colors.green : Colors.red
          ),
          StatusCard(
            title: 'Risk Durumu',
            value: risk,
            icon: Icons.warning_rounded,
            color: riskColor
          ),
          StatusCard(
            title: 'Göz Durumu',
            value: data?.eyeState ?? 'Veri yok',
            icon: Icons.remove_red_eye,
            color: data == null
                ? Colors.grey
                : data.isEyeClosed ? Colors.red : Colors.green
          ),
          StatusCard(
            title: 'Anlık BPM',
            value: data == null ? '0 BPM' : '${data.bpm} BPM',
            icon: Icons.favorite,
            color: data == null || data.bpm == 0 ? Colors.orange : Colors.blue
          ),
          StatusCard(
            title: 'Nabız Durumu',
            value: data?.pulseState ?? 'Veri yok',
            icon: Icons.monitor_heart,
            color: data == null || !data.hasPulse ? Colors.orange : Colors.green
          ),
          const SizedBox(height: 8),
          Text(
            provider.statusMessage,
            style: const TextStyle(color: Colors.grey, fontSize: 13)
          )
        ]
      )
    );
  }
}
