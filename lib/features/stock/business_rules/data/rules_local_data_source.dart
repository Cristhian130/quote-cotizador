import 'package:sqflite/sqflite.dart';

import '../../../../core/database/sqlite_database.dart';
import '../domain/alert_rules.dart';

class RulesLocalDataSource {
  Future<AlertRules?> read() async {
    final db = await SQLiteDatabase.database;
    final rows = await db.query('stock_alert_rules', limit: 1);
    return rows.isEmpty ? null : AlertRules.fromDatabase(rows.first);
  }

  Future<void> save(AlertRules rules, DateTime syncedAt) async {
    final db = await SQLiteDatabase.database;
    await db.insert(
      'stock_alert_rules',
      rules.toDatabase(syncedAt),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
