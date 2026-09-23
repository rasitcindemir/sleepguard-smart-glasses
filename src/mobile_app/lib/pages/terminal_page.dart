import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

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
                  const Icon(Icons.terminal, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bluetooth Terminal Verileri',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16
                      )
                    )
                  ),
                  IconButton(
                    onPressed: provider.clearTerminal,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Terminali Temizle'
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.withOpacity(0.25))
              ),
              child: provider.terminalLines.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz veri gelmedi.\nHC-05 bağlantısını yap ve Arduino’dan veri gönder.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)
                      )
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: provider.terminalLines.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = provider.terminalLines.length - 1 - index;
                        final line = provider.terminalLines[reversedIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '> $line',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontSize: 14
                            )
                          )
                        );
                      }
                    )
            )
          )
        ]
      )
    );
  }
}
