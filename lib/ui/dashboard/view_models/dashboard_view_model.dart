import 'package:flutter/foundation.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/credit_card.dart';
import '../../../domain/models/net_worth_summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/use_cases/calculate_net_worth_use_case.dart';

class DashboardViewModel extends ChangeNotifier {
  final AccountRepository _accountRepo;
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final CalculateNetWorthUseCase _calculateNetWorthUseCase;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isLoading = false;

  NetWorthSummary _netWorth = const NetWorthSummary();
  int _totalIncomeCents = 0;
  int _totalExpenseCents = 0;
  int _totalInvestedCents = 0;

  List<TransactionModel> _recentTransactions = [];
  Map<String, int> _expenseByCategoryCents = {};
  Map<String, CategoryModel> _categoriesMap = {};

  DashboardViewModel({
    required AccountRepository accountRepo,
    required TransactionRepository transactionRepo,
    required CategoryRepository categoryRepo,
    required CalculateNetWorthUseCase calculateNetWorthUseCase,
  })  : _accountRepo = accountRepo,
        _transactionRepo = transactionRepo,
        _categoryRepo = categoryRepo,
        _calculateNetWorthUseCase = calculateNetWorthUseCase;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  NetWorthSummary get netWorth => _netWorth;
  int get totalIncomeCents => _totalIncomeCents;
  int get totalExpenseCents => _totalExpenseCents;
  int get totalInvestedCents => _totalInvestedCents;
  int get netCashFlowCents => _totalIncomeCents - _totalExpenseCents;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  Map<String, int> get expenseByCategoryCents => _expenseByCategoryCents;
  Map<String, CategoryModel> get categoriesMap => _categoriesMap;

  void setPeriod(int year, int month, String userId) {
    _selectedYear = year;
    _selectedMonth = month;
    loadDashboard(userId);
  }

  Future<void> loadDashboard(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accountsFuture = _accountRepo.getAccounts(userId);
      final cardsFuture = _accountRepo.getCreditCards(userId);
      final transactionsFuture = _transactionRepo.getTransactionsByPeriod(
        userId: userId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      final categoriesFuture = _categoryRepo.getCategories(userId);

      final results = await Future.wait([
        accountsFuture,
        cardsFuture,
        transactionsFuture,
        categoriesFuture,
      ]);

      final accounts = results[0] as List<Account>;
      final cards = results[1] as List<CreditCard>;
      final transactions = results[2] as List<TransactionModel>;
      final categories = results[3] as List<CategoryModel>;

      _categoriesMap = {for (var c in categories) c.id: c};
      _netWorth = _calculateNetWorthUseCase.execute(accounts: accounts, creditCards: cards);

      int income = 0;
      int expense = 0;
      int invested = 0;
      final Map<String, int> catExpenseMap = {};

      for (final tx in transactions) {
        if (tx.status != TransactionStatus.PAID) continue;
        switch (tx.type) {
          case TransactionType.INCOME:
            income += tx.amountCents;
            break;
          case TransactionType.EXPENSE:
            expense += tx.amountCents;
            catExpenseMap[tx.categoryId] = (catExpenseMap[tx.categoryId] ?? 0) + tx.amountCents;
            break;
          case TransactionType.INVESTMENT:
            invested += tx.amountCents;
            break;
          case TransactionType.TRANSFER:
            break;
        }
      }

      _totalIncomeCents = income;
      _totalExpenseCents = expense;
      _totalInvestedCents = invested;
      _expenseByCategoryCents = catExpenseMap;
      _recentTransactions = transactions.take(5).toList();
    } catch (_) {
      // Ignora erro em modo offline
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
