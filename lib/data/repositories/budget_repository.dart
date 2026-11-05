import 'package:sqflite/sqflite.dart';
import '../../domain/models/budget.dart';
import '../services/local/sqlite_service.dart';

class BudgetRepository {
  final SqliteService _sqliteService;

  BudgetRepository(this._sqliteService);

  Future<List<Budget>> getBudgetsByPeriod({
    required String userId,
    required int year,
    required int month,
  }) async {
    final db = await _sqliteService.database;
    final rows = await db.query(
      'budgets',
      where: 'user_id = ? AND year = ? AND month = ?',
      whereArgs: [userId, year, month],
    );
    return rows.map(Budget.fromMap).toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final db = await _sqliteService.database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

