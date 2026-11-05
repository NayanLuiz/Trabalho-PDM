import 'package:flutter/material.dart';
import '../accounts_cards/views/accounts_view.dart';
import '../budgets/views/budgets_view.dart';
import '../dashboard/views/dashboard_view.dart';
import '../goals/views/goals_view.dart';
import '../reports/views/reports_view.dart';
import '../settings/views/settings_view.dart';
import '../transactions/views/transactions_view.dart';

class HomeNavScaffold extends StatefulWidget {
  const HomeNavScaffold({super.key});

  @override
  State<HomeNavScaffold> createState() => _HomeNavScaffoldState();
}

class _HomeNavScaffoldState extends State<HomeNavScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    TransactionsView(),
    AccountsView(),
    GoalsView(),
    _MoreHubView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Extrato',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Contas',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}

class _MoreHubView extends StatelessWidget {
  const _MoreHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & Ferramentas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune, color: Color(0xFF059669)),
              title: const Text('Tetos de Gastos por Categoria'),
              subtitle: const Text('Acompanhe limites de 80% e 100%'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetsView()));
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined, color: Color(0xFF2563EB)),
              title: const Text('Exportar Relatórios e Extratos'),
              subtitle: const Text('Gerar arquivos em PDF ou planilha CSV'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsView()));
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, color: Color(0xFF475569)),
              title: const Text('Configurações & Segurança'),
              subtitle: const Text('Tema escuro, PIN local, Biometria e Backup'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

