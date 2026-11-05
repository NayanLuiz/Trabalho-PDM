import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/money_utils.dart';

class CashFlowChart extends StatelessWidget {
  final int incomeCents;
  final int expenseCents;
  final int investedCents;

  const CashFlowChart({
    super.key,
    required this.incomeCents,
    required this.expenseCents,
    required this.investedCents,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = [
      incomeCents / 100.0,
      expenseCents / 100.0,
      investedCents / 100.0,
      100.0,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativo do Mês',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.15,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final String label = groupIndex == 0
                            ? 'Receitas'
                            : groupIndex == 1
                                ? 'Despesas'
                                : 'Aportes';
                        return BarTooltipItem(
                          '$label\n${MoneyUtils.formatCents((rod.toY * 100).round())}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          switch (val.toInt()) {
                            case 0:
                              return const Text('Receitas', style: TextStyle(fontSize: 12));
                            case 1:
                              return const Text('Despesas', style: TextStyle(fontSize: 12));
                            case 2:
                              return const Text('Aportes', style: TextStyle(fontSize: 12));
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
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: incomeCents / 100.0,
                          color: const Color(0xFF059669),
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expenseCents / 100.0,
                          color: const Color(0xFFE11D48),
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: investedCents / 100.0,
                          color: const Color(0xFF2563EB),
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
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

