import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/category.dart';

class SqliteService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        'gestao_financeira_web.db',
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
          await _seedDefaultCategories(db);
        },
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestao_financeira_v1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedDefaultCategories(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance_cents INTEGER NOT NULL DEFAULT 0,
        color TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        limit_cents INTEGER NOT NULL,
        closing_day INTEGER NOT NULL,
        due_day INTEGER NOT NULL,
        color TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        name_normalized TEXT NOT NULL,
        type TEXT NOT NULL,
        color TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        account_id TEXT NULL,
        credit_card_id TEXT NULL,
        category_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        date TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PAID',
        installment_index INTEGER NULL,
        total_installments INTEGER NULL,
        recurring_rule TEXT NULL,
        recurring_group_id TEXT NULL,
        receipt_path TEXT NULL,
        receipt_url TEXT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL,
        FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id) ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
      );
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        target_cents INTEGER NOT NULL,
        current_cents INTEGER NOT NULL DEFAULT 0,
        target_date TEXT NULL,
        category_id TEXT NULL,
        color TEXT NOT NULL,
        icon TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        limit_cents INTEGER NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, category_id, year, month)
      );
    ''');

    await db.execute('CREATE INDEX idx_transactions_period ON transactions(user_id, year, month);');
    await db.execute('CREATE INDEX idx_transactions_category ON transactions(category_id);');
  }

  Future<void> _seedDefaultCategories(Database db) async {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();

    for (final cat in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'user_id': 'local_user',
        'name': cat['name'],
        'name_normalized': CategoryModel.normalizeName(cat['name']!),
        'type': cat['type'],
        'color': cat['color'],
        'is_archived': 0,
        'sync_status': 'synced',
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
