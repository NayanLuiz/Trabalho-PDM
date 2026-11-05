import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/budget.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/budgets_view_model.dart';

class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';
      context.read<BudgetsViewModel>().loadBudgets(userId);
    });
  }

  void _showAddBudgetDialog(BuildContext context, String userId) {
    final vm = context.read<BudgetsViewModel>();
    final limitCtrl = TextEditingController();
    String? selectedCategoryId = vm.expenseCategories.isNotEmpty ? vm.expenseCategories.first.id : null;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Definir Teto Mensal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoria de Despesa'),
                    items: vm.expenseCategories.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedCategoryId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitCtrl,
                    decoration: const InputDecoration(labelText: 'Teto Limite (R\$)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      final limitCents = MoneyUtils.parseToCents(limitCtrl.text);
                      if (limitCents <= 0 || selectedCategoryId == null) return;

                      vm.setBudget(
                        id: const Uuid().v4(),
                        userId: userId,
                        categoryId: selectedCategoryId!,
                        limitCents: limitCents,
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Salvar Teto'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BudgetsViewModel>();
    final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetos de Gastos', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context, userId),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.budgetsWithProgress.isEmpty
              ? const Center(child: Text('Nenhum teto configurado para este mês.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: vm.budgetsWithProgress.length,
                  itemBuilder: (ctx, index) {
                    final item = vm.budgetsWithProgress[index];
                    final res = item.checkResult;

                    Color statusColor;
                    if (res.status == BudgetStatus.EXCEEDED) {
                      statusColor = const Color(0xFFE11D48);
                    } else if (res.status == BudgetStatus.WARNING) {
                      statusColor = const Color(0xFFEA580C);
                    } else {
                      statusColor = const Color(0xFF059669);
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.category.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    res.status == BudgetStatus.EXCEEDED
                                        ? 'Estourado (>100%)'
                                        : res.status == BudgetStatus.WARNING
                                            ? 'Atenção (≥80%)'
                                            : 'Normal',
                                    style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (res.usagePercentage / 100.0).clamp(0.0, 1.0),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: statusColor,
                              backgroundColor: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Gasto: ${MoneyUtils.formatCents(res.spentCents)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('Teto: ${MoneyUtils.formatCents(res.limitCents)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

