import 'package:sqflite/sqflite.dart';
import '../../domain/models/category.dart';
import '../services/local/sqlite_service.dart';

class CategoryRepository {
  final SqliteService _sqliteService;

  CategoryRepository(this._sqliteService);

  Future<List<CategoryModel>> getCategories(String userId) async {
    final db = await _sqliteService.database;
    final rows = await db.query(
      'categories',
      where: '(user_id = ? OR user_id = "local_user") AND is_archived = 0',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final db = await _sqliteService.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
