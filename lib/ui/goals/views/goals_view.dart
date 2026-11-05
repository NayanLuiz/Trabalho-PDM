import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/goal.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/goals_view_model.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';
      context.read<GoalsViewModel>().loadGoals(userId);
    });
  }

  void _showAddGoalDialog(BuildContext context, String userId) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
              const Text('Nova Meta / Caixinha',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome da Meta (ex: Reserva de Emergência)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final targetCents = MoneyUtils.parseToCents(targetCtrl.text);
                  if (name.isEmpty || targetCents <= 0) return;

                  final now = DateTime.now().toIso8601String();
                  final goal = Goal(
                    id: const Uuid().v4(),
                    userId: userId,
                    name: name,
                    targetCents: targetCents,
                    color: '#059669',
                    icon: 'flag',
                    createdAt: now,
                    updatedAt: now,
                  );

                  context.read<GoalsViewModel>().createGoal(goal);
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar Meta'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDepositDialog(BuildContext context, Goal goal, String userId) {
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Aportar na Meta: ${goal.name}'),
          content: TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(labelText: 'Valor do Aporte (R\$)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final amountCents = MoneyUtils.parseToCents(amountCtrl.text);
                if (amountCents > 0) {
                  context.read<GoalsViewModel>().deposit(goal.id, amountCents, userId);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Confirmar Aporte'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoalsViewModel>();
    final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas & Caixinhas', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context, userId),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.goals.isEmpty
              ? const Center(child: Text('Nenhuma meta cadastrada. Crie uma para começar!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: vm.goals.length,
                  itemBuilder: (ctx, index) {
                    final goal = vm.goals[index];
                    final pct = goal.progressPercentage;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(goal.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: pct / 100.0,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFF059669),
                              backgroundColor: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Guardado: ${MoneyUtils.formatCents(goal.currentCents)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('Alvo: ${MoneyUtils.formatCents(goal.targetCents)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.savings_outlined, size: 16),
                                label: const Text('Aportar'),
                                onPressed: () => _showDepositDialog(context, goal, userId),
                              ),
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

