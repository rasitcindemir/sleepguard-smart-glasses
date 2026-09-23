import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BluetoothProvider>();

    final spots = provider.sensorHistory
        .where((data) => data.bpm > 0)
        .map((data) => FlSpot(data.time, data.bpm.toDouble()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.show_chart, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'BPM Zaman Grafiği',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900
                      )
                    )
                  ),
                  IconButton(
                    onPressed: provider.clearChart,
                    icon: const Icon(Icons.restart_alt),
                    color: Colors.orange,
                    tooltip: 'Grafiği Sıfırla'
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                child: spots.length < 2
                    ? const Center(
                        child: Text(
                          'Grafik çizmek için en az 2 adet geçerli BPM verisi bekleniyor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15)
                        )
                      )
                    : LineChart(
                        LineChartData(
                          minY: 50,
                          maxY: 120,
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.08),
                                strokeWidth: 1
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.05),
                                strokeWidth: 1
                              );
                            }
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              axisNameWidget: const Text('BPM', style: TextStyle(color: Colors.grey)),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)
                                  );
                                }
                              )
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text('Zaman / saniye', style: TextStyle(color: Colors.grey)),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)
                                  );
                                }
                              )
                            )
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.blue.withOpacity(0.25))
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 4,
                              color: Colors.blue,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.12)
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.black
                                  );
                                }
                              )
                            )
                          ]
                        )
                      )
              )
            )
          )
        ]
      )
    );
  }
}
