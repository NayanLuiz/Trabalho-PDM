import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../local/sqlite_service.dart';

/// Servico de sincronizacao hibrida (Offline-First).
class FirestoreSyncService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final SqliteService _sqliteService;

  FirestoreSyncService(this._sqliteService);

  Future<void> syncAll(String userId) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final db = await _sqliteService.database;
    await _syncCollection(db, firestore, 'accounts', userId);
    await _syncCollection(db, firestore, 'credit_cards', userId);
    await _syncCollection(db, firestore, 'categories', userId);
    await _syncCollection(db, firestore, 'transactions', userId);
    await _syncCollection(db, firestore, 'goals', userId);
    await _syncCollection(db, firestore, 'budgets', userId);
  }

  Future<void> _syncCollection(Database db, FirebaseFirestore firestore, String table, String userId) async {
    try {
      final pendingRows = await db.query(
        table,
        where: 'user_id = ? AND sync_status != ?',
        whereArgs: [userId, 'synced'],
      );

      for (final row in pendingRows) {
        final id = row['id'] as String;
        final status = row['sync_status'] as String;

        if (status == 'pending_delete') {
          await firestore.collection('users').doc(userId).collection(table).doc(id).delete();
          await db.delete(table, where: 'id = ?', whereArgs: [id]);
        } else {
          final Map<String, dynamic> data = Map.from(row);
          data.remove('sync_status');
          await firestore
              .collection('users')
              .doc(userId)
              .collection(table)
              .doc(id)
              .set(data, SetOptions(merge: true));

          await db.update(
            table,
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection(table)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['sync_status'] = 'synced';
        await db.insert(
          table,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {
      // Ignora erro em modo offline
    }
  }
}
