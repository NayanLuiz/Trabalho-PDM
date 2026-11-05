import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/export/export_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';
import '../../transactions/view_models/transactions_view_model.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionsViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final exportService = ExportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Extratos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Geração de Relatórios Mensais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Competência selecionada: ${txVm.selectedMonth.toString().padLeft(2, '0')}/${txVm.selectedYear}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE4E6),
                  child: Icon(Icons.picture_as_pdf, color: Color(0xFFE11D48)),
                ),
                title: const Text('Exportar Extrato em PDF'),
                subtitle: const Text('Relatório visual formatado para compartilhamento'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await exportService.exportMonthlyTransactionsToPdf(
                    txVm.selectedYear,
                    txVm.selectedMonth,
                    txVm.transactions,
                    dashVm.totalIncomeCents,
                    dashVm.totalExpenseCents,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD1FAE5),
                  child: Icon(Icons.table_chart, color: Color(0xFF059669)),
                ),
                title: const Text('Exportar Planilha CSV'),
                subtitle: const Text('Dados tabulares compatíveis com Excel e Google Planilhas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await exportService.exportMonthlyTransactionsToCsv(
                    txVm.selectedYear,
                    txVm.selectedMonth,
                    txVm.transactions,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

