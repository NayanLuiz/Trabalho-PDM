import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/category.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, int> expenseByCategoryCents;
  final Map<String, CategoryModel> categoriesMap;

  const CategoryPieChart({
    super.key,
    required this.expenseByCategoryCents,
    required this.categoriesMap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseByCategoryCents.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Nenhuma despesa registrada neste mês.')),
        ),
      );
    }

    final int totalExpense = expenseByCategoryCents.values.fold(0, (a, b) => a + b);

    final sections = expenseByCategoryCents.entries.map((entry) {
      final category = categoriesMap[entry.key];
      final colorHex = category?.color ?? '#475569';
      final colorInt = int.tryParse(colorHex.replaceAll('#', '0xFF')) ?? 0xFF475569;
      final pct = (entry.value / totalExpense) * 100.0;

      return PieChartSectionData(
        value: entry.value / 100.0,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        color: Color(colorInt),
        radius: 45,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Despesas por Categoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: expenseByCategoryCents.entries.map((e) {
                final cat = categoriesMap[e.key];
                final colorHex = cat?.color ?? '#475569';
                final colorInt = int.tryParse(colorHex.replaceAll('#', '0xFF')) ?? 0xFF475569;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, color: Color(colorInt)),
                    const SizedBox(width: 4),
                    Text(
                      '${cat?.name ?? 'Outros'}: ${MoneyUtils.formatCents(e.value)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
