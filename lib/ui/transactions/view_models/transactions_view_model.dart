import 'package:flutter/foundation.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/local/notification_service.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/credit_card.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/use_cases/check_budget_limit_use_case.dart';
import '../../../domain/use_cases/generate_recurring_dates_use_case.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final AccountRepository _accountRepo;
  final NotificationService _notificationService;
  final CheckBudgetLimitUseCase _checkBudgetLimitUseCase;
  final GenerateRecurringDatesUseCase _generateRecurringDatesUseCase;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<Account> _accounts = [];
  List<CreditCard> _creditCards = [];
  bool _isLoading = false;

  TransactionsViewModel({
    required TransactionRepository transactionRepo,
    required CategoryRepository categoryRepo,
    required AccountRepository accountRepo,
    required NotificationService notificationService,
    required CheckBudgetLimitUseCase checkBudgetLimitUseCase,
    required GenerateRecurringDatesUseCase generateRecurringDatesUseCase,
  })  : _transactionRepo = transactionRepo,
        _categoryRepo = categoryRepo,
        _accountRepo = accountRepo,
        _notificationService = notificationService,
        _checkBudgetLimitUseCase = checkBudgetLimitUseCase,
        _generateRecurringDatesUseCase = generateRecurringDatesUseCase;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<Account> get accounts => _accounts;
  List<CreditCard> get creditCards => _creditCards;
  bool get isLoading => _isLoading;

  void setPeriod(int year, int month, String userId) {
    _selectedYear = year;
    _selectedMonth = month;
    loadTransactions(userId);
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _transactionRepo.getTransactionsByPeriod(
          userId: userId,
          year: _selectedYear,
          month: _selectedMonth,
        ),
        _categoryRepo.getCategories(userId),
        _accountRepo.getAccounts(userId),
        _accountRepo.getCreditCards(userId),
      ]);

      _transactions = results[0] as List<TransactionModel>;
      _categories = results[1] as List<CategoryModel>;
      _accounts = results[2] as List<Account>;
      _creditCards = results[3] as List<CreditCard>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTransactionWithInstallments({
    required TransactionModel baseTx,
    int installments = 1,
  }) async {
    final dates = _generateRecurringDatesUseCase.execute(
      initialDate: baseTx.date,
      totalInstallmentsOrMonths: installments,
    );

    for (int i = 0; i < dates.length; i++) {
      final dateStr = dates[i];
      final parts = dateStr.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);

      final tx = TransactionModel(
        id: '${baseTx.id}_${i + 1}',
        userId: baseTx.userId,
        accountId: baseTx.accountId,
        creditCardId: baseTx.creditCardId,
        categoryId: baseTx.categoryId,
        type: baseTx.type,
        amountCents: baseTx.amountCents,
        date: dateStr,
        year: y,
        month: m,
        description: installments > 1
            ? '${baseTx.description} (${i + 1}/$installments)'
            : baseTx.description,
        status: baseTx.status,
        installmentIndex: installments > 1 ? (i + 1) : null,
        totalInstallments: installments > 1 ? installments : null,
        receiptPath: baseTx.receiptPath,
        createdAt: baseTx.createdAt,
        updatedAt: baseTx.updatedAt,
      );

      await _transactionRepo.saveTransaction(tx);
    }

    await loadTransactions(baseTx.userId);
  }

  Future<void> deleteTransaction(String id, String userId) async {
    await _transactionRepo.deleteTransaction(id, userId);
    await loadTransactions(userId);
  }
}
