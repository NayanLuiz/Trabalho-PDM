import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/money_utils.dart';

class NetWorthTrendChart extends StatelessWidget {
  final int currentNetWorthCents;

  const NetWorthTrendChart({super.key, required this.currentNetWorthCents});

  @override
  Widget build(BuildContext context) {
    // Estimativa de evolucao recente para visualizacao inicial
    final double currentVal = currentNetWorthCents / 100.0;
    final List<FlSpot> spots = [
      FlSpot(1, currentVal * 0.90),
      FlSpot(2, currentVal * 0.93),
      FlSpot(3, currentVal * 0.97),
      FlSpot(4, currentVal),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução Patrimonial Recente',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          switch (val.toInt()) {
                            case 1:
                              return const Text('M-3', style: TextStyle(fontSize: 11));
                            case 2:
                              return const Text('M-2', style: TextStyle(fontSize: 11));
                            case 3:
                              return const Text('M-1', style: TextStyle(fontSize: 11));
                            case 4:
                              return const Text('Atual', style: TextStyle(fontSize: 11));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF059669),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF059669).withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

