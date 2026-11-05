import 'package:flutter/foundation.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/services/local/notification_service.dart';
import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/use_cases/check_budget_limit_use_case.dart';

class BudgetWithProgress {
  final Budget budget;
  final CategoryModel category;
  final BudgetCheckResult checkResult;

  const BudgetWithProgress({
    required this.budget,
    required this.category,
    required this.checkResult,
  });
}

class BudgetsViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepo;
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final CheckBudgetLimitUseCase _checkBudgetLimitUseCase;
  final NotificationService _notificationService;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<BudgetWithProgress> _budgetsWithProgress = [];
  List<CategoryModel> _expenseCategories = [];
  bool _isLoading = false;

  BudgetsViewModel({
    required BudgetRepository budgetRepo,
    required TransactionRepository transactionRepo,
    required CategoryRepository categoryRepo,
    required CheckBudgetLimitUseCase checkBudgetLimitUseCase,
    required NotificationService notificationService,
  })  : _budgetRepo = budgetRepo,
        _transactionRepo = transactionRepo,
        _categoryRepo = categoryRepo,
        _checkBudgetLimitUseCase = checkBudgetLimitUseCase,
        _notificationService = notificationService;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  List<BudgetWithProgress> get budgetsWithProgress => _budgetsWithProgress;
  List<CategoryModel> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;

  void setPeriod(int year, int month, String userId) {
    _selectedYear = year;
    _selectedMonth = month;
    loadBudgets(userId);
  }

  Future<void> loadBudgets(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final budgetsFuture = _budgetRepo.getBudgetsByPeriod(
        userId: userId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      final categoriesFuture = _categoryRepo.getCategories(userId);

      final results = await Future.wait([budgetsFuture, categoriesFuture]);
      final budgets = results[0] as List<Budget>;
      final categories = results[1] as List<CategoryModel>;

      _expenseCategories = categories.where((c) => c.type == CategoryType.EXPENSE).toList();
      final catMap = {for (var c in categories) c.id: c};

      final List<BudgetWithProgress> progressList = [];
      for (final b in budgets) {
        final cat = catMap[b.categoryId];
        if (cat == null) continue;

        final spentCents = await _transactionRepo.getMonthlySpentByCategory(
          userId: userId,
          categoryId: b.categoryId,
          year: _selectedYear,
          month: _selectedMonth,
        );

        final checkResult = _checkBudgetLimitUseCase.execute(
          categoryId: b.categoryId,
          limitCents: b.limitCents,
          spentCents: spentCents,
        );

        if (checkResult.shouldTrigger80Alert || checkResult.shouldTrigger100Alert) {
          _notificationService.showBudgetWarningNotification(
            id: b.id.hashCode,
            categoryName: cat.name,
            percentage: checkResult.usagePercentage,
          );
        }

        progressList.add(BudgetWithProgress(
          budget: b,
          category: cat,
          checkResult: checkResult,
        ));
      }

      _budgetsWithProgress = progressList;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBudget({
    required String id,
    required String userId,
    required String categoryId,
    required int limitCents,
  }) async {
    final now = DateTime.now().toIso8601String();
    final budget = Budget(
      id: id,
      userId: userId,
      categoryId: categoryId,
      year: _selectedYear,
      month: _selectedMonth,
      limitCents: limitCents,
      createdAt: now,
      updatedAt: now,
    );
    await _budgetRepo.saveBudget(budget);
    await loadBudgets(userId);
  }
}
