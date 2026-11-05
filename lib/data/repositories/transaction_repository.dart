import 'package:sqflite/sqflite.dart';
import '../../domain/models/transaction.dart';
import '../services/local/sqlite_service.dart';

class TransactionRepository {
  final SqliteService _sqliteService;

  TransactionRepository(this._sqliteService);

  Future<List<TransactionModel>> getTransactionsByPeriod({
    required String userId,
    required int year,
    required int month,
  }) async {
    final db = await _sqliteService.database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ? AND year = ? AND month = ?',
      whereArgs: [userId, year, month],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    final db = await _sqliteService.database;
    await db.transaction((txn) async {
      await txn.insert(
        'transactions',
        tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Se vinculado a conta e ja pago, atualiza saldo da conta
      if (tx.accountId != null && tx.status == TransactionStatus.PAID) {
        if (tx.type == TransactionType.INCOME) {
          await txn.rawUpdate(
            'UPDATE accounts SET balance_cents = balance_cents + ? WHERE id = ?',
            [tx.amountCents, tx.accountId],
          );
        } else if (tx.type == TransactionType.EXPENSE || tx.type == TransactionType.INVESTMENT) {
          await txn.rawUpdate(
            'UPDATE accounts SET balance_cents = balance_cents - ? WHERE id = ?',
            [tx.amountCents, tx.accountId],
          );
        }
      }
    });
  }

  Future<void> deleteTransaction(String id, String userId) async {
    final db = await _sqliteService.database;
    await db.update(
      'transactions',
      {'sync_status': 'pending_delete'},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> getMonthlySpentByCategory({
    required String userId,
    required String categoryId,
    required int year,
    required int month,
  }) async {
    final db = await _sqliteService.database;
    final res = await db.rawQuery('''
      SELECT SUM(amount_cents) as total FROM transactions
      WHERE user_id = ? AND category_id = ? AND year = ? AND month = ? AND type = 'EXPENSE'
    ''', [userId, categoryId, year, month]);

    return (res.first['total'] as int?) ?? 0;
  }
}

