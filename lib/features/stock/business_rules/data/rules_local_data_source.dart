import 'package:sqflite/sqflite.dart';

import '../../../../core/database/sqlite_database.dart';
import '../domain/business_rule.dart';

class RulesLocalDataSource {
  Future<List<BusinessRule>> read() async {
    final db = await SQLiteDatabase.database;
    final rows = await db.query(
      'stock_business_rules',
      orderBy: 'created_at ASC',
    );
    return rows.map(BusinessRule.fromDatabase).toList(growable: false);
  }

  Future<void> replaceAll(List<BusinessRule> rules) async {
    final db = await SQLiteDatabase.database;
    await db.transaction((txn) async {
      await txn.delete('stock_business_rules');
      for (final rule in rules) {
        await txn.insert(
          'stock_business_rules',
          rule.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> save(BusinessRule rule) async {
    final db = await SQLiteDatabase.database;
    await db.insert(
      'stock_business_rules',
      rule.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await SQLiteDatabase.database;
    await db.delete('stock_business_rules', where: 'id = ?', whereArgs: [id]);
  }
}
