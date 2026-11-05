import 'package:sqflite/sqflite.dart';
import '../../domain/models/account.dart';
import '../../domain/models/credit_card.dart';
import '../services/local/sqlite_service.dart';

class AccountRepository {
  final SqliteService _sqliteService;

  AccountRepository(this._sqliteService);

  Future<List<Account>> getAccounts(String userId) async {
    final db = await _sqliteService.database;
    final rows = await db.query(
      'accounts',
      where: 'user_id = ? AND is_archived = 0',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(Account.fromMap).toList();
  }

  Future<void> saveAccount(Account account) async {
    final db = await _sqliteService.database;
    await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CreditCard>> getCreditCards(String userId) async {
    final db = await _sqliteService.database;
    final cardRows = await db.query(
      'credit_cards',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final List<CreditCard> cards = [];
    for (final row in cardRows) {
      final cardId = row['id'] as String;
      // Calcula fatura atual (despesas vinculadas ao cartao nao pagas)
      final invoiceResult = await db.rawQuery('''
        SELECT SUM(amount_cents) as total FROM transactions
        WHERE credit_card_id = ? AND status = 'PENDING'
      ''', [cardId]);

      final int invoiceCents = (invoiceResult.first['total'] as int?) ?? 0;
      cards.add(CreditCard.fromMap(row, currentInvoiceCents: invoiceCents));
    }

    return cards;
  }

  Future<void> saveCreditCard(CreditCard card) async {
    final db = await _sqliteService.database;
    await db.insert(
      'credit_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

