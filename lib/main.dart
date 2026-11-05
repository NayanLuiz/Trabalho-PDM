import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/services/export/export_service.dart';
import 'data/services/local/local_auth_service.dart';
import 'data/services/local/notification_service.dart';
import 'data/services/local/sqlite_service.dart';
import 'data/services/remote/firebase_auth_service.dart';
import 'data/services/remote/firestore_sync_service.dart';
import 'domain/use_cases/calculate_net_worth_use_case.dart';
import 'domain/use_cases/check_budget_limit_use_case.dart';
import 'domain/use_cases/generate_recurring_dates_use_case.dart';
import 'ui/accounts_cards/view_models/accounts_view_model.dart';
import 'ui/auth/view_models/auth_view_model.dart';
import 'ui/budgets/view_models/budgets_view_model.dart';
import 'ui/dashboard/view_models/dashboard_view_model.dart';
import 'ui/goals/view_models/goals_view_model.dart';
import 'ui/settings/view_models/settings_view_model.dart';
import 'ui/transactions/view_models/transactions_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instancias Singleton dos Servicos
  final sqliteService = SqliteService();
  final localAuthService = LocalAuthService();
  final notificationService = NotificationService();
  final firebaseAuthService = FirebaseAuthService();
  final firestoreSyncService = FirestoreSyncService(sqliteService);
  final exportService = ExportService();

  // Inicializacao dos drivers locais
  await notificationService.init();

  // Instancias dos Casos de Uso (Domain Logic Layer)
  final calculateNetWorthUseCase = CalculateNetWorthUseCase();
  final checkBudgetLimitUseCase = CheckBudgetLimitUseCase();
  final generateRecurringDatesUseCase = GenerateRecurringDatesUseCase();

  // Instancias dos Repositorios (Data Layer - SSOT)
  final accountRepo = AccountRepository(sqliteService);
  final transactionRepo = TransactionRepository(sqliteService);
  final categoryRepo = CategoryRepository(sqliteService);
  final goalRepo = GoalRepository(sqliteService);
  final budgetRepo = BudgetRepository(sqliteService);

  runApp(
    MultiProvider(
      providers: [
        // Services & UseCases
        Provider<SqliteService>.value(value: sqliteService),
        Provider<ExportService>.value(value: exportService),
        Provider<CalculateNetWorthUseCase>.value(value: calculateNetWorthUseCase),
        Provider<CheckBudgetLimitUseCase>.value(value: checkBudgetLimitUseCase),
        Provider<GenerateRecurringDatesUseCase>.value(value: generateRecurringDatesUseCase),

        // Repositories
        Provider<AccountRepository>.value(value: accountRepo),
        Provider<TransactionRepository>.value(value: transactionRepo),
        Provider<CategoryRepository>.value(value: categoryRepo),
        Provider<GoalRepository>.value(value: goalRepo),
        Provider<BudgetRepository>.value(value: budgetRepo),

        // ViewModels (UI State & Presentation Logic)
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            firebaseAuthService: firebaseAuthService,
            localAuthService: localAuthService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            accountRepo: accountRepo,
            transactionRepo: transactionRepo,
            categoryRepo: categoryRepo,
            calculateNetWorthUseCase: calculateNetWorthUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountsViewModel(accountRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionsViewModel(
            transactionRepo: transactionRepo,
            categoryRepo: categoryRepo,
            accountRepo: accountRepo,
            notificationService: notificationService,
            checkBudgetLimitUseCase: checkBudgetLimitUseCase,
            generateRecurringDatesUseCase: generateRecurringDatesUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalsViewModel(goalRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetsViewModel(
            budgetRepo: budgetRepo,
            transactionRepo: transactionRepo,
            categoryRepo: categoryRepo,
            checkBudgetLimitUseCase: checkBudgetLimitUseCase,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            localAuthService: localAuthService,
            firestoreSyncService: firestoreSyncService,
          )..init(),
        ),
      ],
      child: const ControleFinanceiroApp(),
    ),
  );
}

