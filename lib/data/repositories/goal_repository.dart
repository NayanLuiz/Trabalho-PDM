import 'package:sqflite/sqflite.dart';
import '../../domain/models/goal.dart';
import '../services/local/sqlite_service.dart';

class GoalRepository {
  final SqliteService _sqliteService;

  GoalRepository(this._sqliteService);

  Future<List<Goal>> getGoals(String userId) async {
    final db = await _sqliteService.database;
    final rows = await db.query(
      'goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Goal.fromMap).toList();
  }

  Future<void> saveGoal(Goal goal) async {
    final db = await _sqliteService.database;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> depositToGoal(String goalId, int amountCents) async {
    final db = await _sqliteService.database;
    await db.rawUpdate('''
      UPDATE goals
      SET current_cents = current_cents + ?,
          updated_at = ?
      WHERE id = ?
    ''', [amountCents, DateTime.now().toIso8601String(), goalId]);
  }
}

