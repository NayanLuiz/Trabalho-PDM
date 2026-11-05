import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/civil_date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/transaction.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/transactions_view_model.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';
      context.read<TransactionsViewModel>().loadTransactions(userId);
    });
  }

  void _showAddTransactionDialog(BuildContext context, String userId) {
    final vm = context.read<TransactionsViewModel>();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final installmentsCtrl = TextEditingController(text: '1');
    TransactionType selectedType = TransactionType.EXPENSE;
    String? selectedCategoryId = vm.categories.isNotEmpty ? vm.categories.first.id : null;
    String? selectedAccountId = vm.accounts.isNotEmpty ? vm.accounts.first.id : null;
    String? selectedCreditCardId;
    String? attachedReceiptPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Novo Lançamento',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(value: TransactionType.EXPENSE, label: Text('Despesa')),
                        ButtonSegment(value: TransactionType.INCOME, label: Text('Receita')),
                        ButtonSegment(value: TransactionType.INVESTMENT, label: Text('Aporte')),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (set) {
                        setModalState(() => selectedType = set.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: vm.categories.map((c) {
                        return DropdownMenuItem(value: c.id, child: Text(c.name));
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCategoryId = val),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: selectedAccountId,
                      decoration: const InputDecoration(labelText: 'Conta / Carteira'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Nenhuma (usar Cartão)')),
                        ...vm.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                      ],
                      onChanged: (val) => setModalState(() {
                        selectedAccountId = val;
                        if (val != null) selectedCreditCardId = null;
                      }),
                    ),
                    if (selectedAccountId == null && vm.creditCards.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: selectedCreditCardId,
                        decoration: const InputDecoration(labelText: 'Cartão de Crédito'),
                        items: vm.creditCards.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setModalState(() => selectedCreditCardId = val),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: installmentsCtrl,
                      decoration: const InputDecoration(labelText: 'Nº de Parcelas (1 = à vista)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: Text(attachedReceiptPath != null ? 'Comprovante Anexado' : 'Anexar Foto/PDF'),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              setModalState(() => attachedReceiptPath = image.path);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final desc = descCtrl.text.trim();
                        final amountCents = MoneyUtils.parseToCents(amountCtrl.text);
                        if (desc.isEmpty || amountCents <= 0 || selectedCategoryId == null) return;

                        final installments = int.tryParse(installmentsCtrl.text) ?? 1;
                        final now = DateTime.now().toIso8601String();
                        final todayDate = CivilDateUtils.today();
                        final parts = todayDate.split('-');

                        final baseTx = TransactionModel(
                          id: const Uuid().v4(),
                          userId: userId,
                          accountId: selectedAccountId,
                          creditCardId: selectedCreditCardId,
                          categoryId: selectedCategoryId!,
                          type: selectedType,
                          amountCents: installments > 1 ? (amountCents ~/ installments) : amountCents,
                          date: todayDate,
                          year: int.parse(parts[0]),
                          month: int.parse(parts[1]),
                          description: desc,
                          receiptPath: attachedReceiptPath,
                          createdAt: now,
                          updatedAt: now,
                        );

                        vm.saveTransactionWithInstallments(baseTx: baseTx, installments: installments);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Salvar Lançamento'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();
    final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context, userId),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.transactions.isEmpty
              ? const Center(child: Text('Nenhum lançamento no período selecionado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: vm.transactions.length,
                  itemBuilder: (ctx, index) {
                    final tx = vm.transactions[index];
                    final isIncome = tx.type == TransactionType.INCOME;
                    final isInvestment = tx.type == TransactionType.INVESTMENT;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome
                              ? const Color(0xFFD1FAE5)
                              : isInvestment
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFFFE4E6),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : isInvestment
                                    ? Icons.trending_up
                                    : Icons.arrow_upward,
                            color: isIncome
                                ? const Color(0xFF059669)
                                : isInvestment
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE11D48),
                          ),
                        ),
                        title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${CivilDateUtils.toBrazilianFormat(tx.date)} • ${tx.type.name}${tx.receiptPath != null ? " 📎" : ""}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              MoneyUtils.formatCents(tx.amountCents),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome
                                    ? const Color(0xFF059669)
                                    : isInvestment
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE11D48),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                              onPressed: () => vm.deleteTransaction(tx.id, userId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, userId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

