import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/money_utils.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/credit_card.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/accounts_view_model.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({super.key});

  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';
      context.read<AccountsViewModel>().loadData(userId);
    });
  }

  void _showAddAccountDialog(BuildContext context, String userId) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    AccountType selectedType = AccountType.CHECKING;

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
                  const Text('Nova Carteira / Conta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da Conta (ex: Nubank, NuInvest)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: balanceCtrl,
                    decoration: const InputDecoration(labelText: 'Saldo Inicial (R\$)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AccountType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de Carteira'),
                    items: const [
                      DropdownMenuItem(value: AccountType.CHECKING, child: Text('Conta Corrente')),
                      DropdownMenuItem(value: AccountType.SAVINGS, child: Text('Poupança')),
                      DropdownMenuItem(value: AccountType.INVESTMENT, child: Text('Investimentos / Corretora')),
                      DropdownMenuItem(value: AccountType.CASH, child: Text('Dinheiro Físico')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final balanceCents = MoneyUtils.parseToCents(balanceCtrl.text);
                      final now = DateTime.now().toIso8601String();

                      final acc = Account(
                        id: const Uuid().v4(),
                        userId: userId,
                        name: name,
                        type: selectedType,
                        balanceCents: balanceCents,
                        color: '#059669',
                        createdAt: now,
                        updatedAt: now,
                      );

                      context.read<AccountsViewModel>().addAccount(acc);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Salvar Carteira'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCardDialog(BuildContext context, String userId) {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    final closingCtrl = TextEditingController(text: '20');
    final dueCtrl = TextEditingController(text: '28');

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
              const Text('Novo Cartão de Crédito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Cartão (ex: Cartão Inter Black)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitCtrl,
                decoration: const InputDecoration(labelText: 'Limite Total (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: closingCtrl,
                      decoration: const InputDecoration(labelText: 'Dia Fechamento'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dueCtrl,
                      decoration: const InputDecoration(labelText: 'Dia Vencimento'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final limitCents = MoneyUtils.parseToCents(limitCtrl.text);
                  final closing = int.tryParse(closingCtrl.text) ?? 20;
                  final due = int.tryParse(dueCtrl.text) ?? 28;
                  final now = DateTime.now().toIso8601String();

                  final card = CreditCard(
                    id: const Uuid().v4(),
                    userId: userId,
                    name: name,
                    limitCents: limitCents,
                    closingDay: closing,
                    dueDay: due,
                    color: '#7C3AED',
                    createdAt: now,
                    updatedAt: now,
                  );

                  context.read<AccountsViewModel>().addCreditCard(card);
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar Cartão'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccountsViewModel>();
    final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas & Cartões', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carteiras & Contas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Conta'),
                      onPressed: () => _showAddAccountDialog(context, userId),
                    ),
                  ],
                ),
                ...vm.accounts.map((acc) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF059669).withOpacity(0.15),
                        child: Icon(
                          acc.type == AccountType.INVESTMENT
                              ? Icons.trending_up
                              : acc.type == AccountType.SAVINGS
                                  ? Icons.savings
                                  : Icons.account_balance,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(acc.type.name),
                      trailing: Text(
                        MoneyUtils.formatCents(acc.balanceCents),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: acc.balanceCents >= 0 ? const Color(0xFF059669) : Colors.red,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cartões de Crédito',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Cartão'),
                      onPressed: () => _showAddCardDialog(context, userId),
                    ),
                  ],
                ),
                ...vm.creditCards.map((card) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEDE9FE),
                        child: Icon(Icons.credit_card, color: Color(0xFF7C3AED)),
                      ),
                      title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Fecha dia ${card.closingDay} • Vence dia ${card.dueDay}\nDisponível: ${MoneyUtils.formatCents(card.availableLimitCents)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Fatura Aberta', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            MoneyUtils.formatCents(card.currentInvoiceCents),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

