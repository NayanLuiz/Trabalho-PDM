import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/money_utils.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/net_worth_trend_chart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';
      context.read<DashboardViewModel>().loadDashboard(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final userId = context.read<AuthViewModel>().currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral & Patrimônio', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.loadDashboard(userId),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => vm.loadDashboard(userId),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Period Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Competência: ${vm.selectedMonth.toString().padLeft(2, '0')}/${vm.selectedYear}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              int m = vm.selectedMonth - 1;
                              int y = vm.selectedYear;
                              if (m < 1) {
                                m = 12;
                                y -= 1;
                              }
                              vm.setPeriod(y, m, userId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              int m = vm.selectedMonth + 1;
                              int y = vm.selectedYear;
                              if (m > 12) {
                                m = 1;
                                y += 1;
                              }
                              vm.setPeriod(y, m, userId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Card de Patrimonio Liquido
                  Card(
                    color: const Color(0xFF0F172A),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
                              SizedBox(width: 8),
                              Text('Patrimônio Líquido Total',
                                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            MoneyUtils.formatCents(vm.netWorth.netWorthCents),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Investimentos',
                                      style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    MoneyUtils.formatCents(vm.netWorth.totalInInvestmentsCents),
                                    style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Contas & Carteiras',
                                      style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    MoneyUtils.formatCents(vm.netWorth.totalInCheckingCents +
                                        vm.netWorth.totalInSavingsCents +
                                        vm.netWorth.totalCashCents),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Faturas Cartões',
                                      style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    MoneyUtils.formatCents(vm.netWorth.totalCreditCardDebtCents),
                                    style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumo Fluxo de Caixa (3 cards)
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Receitas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  MoneyUtils.formatCents(vm.totalIncomeCents),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Despesas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  MoneyUtils.formatCents(vm.totalExpenseCents),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Aportes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  MoneyUtils.formatCents(vm.totalInvestedCents),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Graficos Interativos
                  CashFlowChart(
                    incomeCents: vm.totalIncomeCents,
                    expenseCents: vm.totalExpenseCents,
                    investedCents: vm.totalInvestedCents,
                  ),
                  const SizedBox(height: 16),
                  CategoryPieChart(
                    expenseByCategoryCents: vm.expenseByCategoryCents,
                    categoriesMap: vm.categoriesMap,
                  ),
                  const SizedBox(height: 16),
                  NetWorthTrendChart(
                    currentNetWorthCents: vm.netWorth.netWorthCents,
                  ),
                ],
              ),
            ),
    );
  }
}

