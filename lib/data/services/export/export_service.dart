import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/civil_date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/transaction.dart';

class ExportService {
  Future<void> exportMonthlyTransactionsToCsv(
    int year,
    int month,
    List<TransactionModel> transactions,
  ) async {
    final List<List<dynamic>> rows = [
      ['Data', 'Tipo', 'Descricao', 'Valor (R\$)', 'Status']
    ];

    for (final tx in transactions) {
      rows.add([
        CivilDateUtils.toBrazilianFormat(tx.date),
        tx.type.name,
        tx.description,
        (tx.amountCents / 100.0).toStringAsFixed(2),
        tx.status.name,
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);
    final Directory directory = await getTemporaryDirectory();
    final String path = '${directory.path}/extrato_${year}_${month.toString().padLeft(2, '0')}.csv';
    final File file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Extrato Financeiro $month/$year');
  }

  Future<void> exportMonthlyTransactionsToPdf(
    int year,
    int month,
    List<TransactionModel> transactions,
    int totalIncomeCents,
    int totalExpenseCents,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório Financeiro Mensal - $month/$year',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receitas: ${MoneyUtils.formatCents(totalIncomeCents)}'),
                  pw.Text('Despesas: ${MoneyUtils.formatCents(totalExpenseCents)}'),
                  pw.Text(
                    'Saldo: ${MoneyUtils.formatCents(totalIncomeCents - totalExpenseCents)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Data', 'Tipo', 'Descrição', 'Valor'],
                data: transactions.map((tx) {
                  return [
                    CivilDateUtils.toBrazilianFormat(tx.date),
                    tx.type.name,
                    tx.description,
                    MoneyUtils.formatCents(tx.amountCents),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final Directory directory = await getTemporaryDirectory();
    final String path = '${directory.path}/relatorio_${year}_${month.toString().padLeft(2, '0')}.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'Relatório Financeiro PDF $month/$year');
  }
}

