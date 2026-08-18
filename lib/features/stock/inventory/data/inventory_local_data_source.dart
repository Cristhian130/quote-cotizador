import 'package:sqflite/sqflite.dart';

import '../../../../core/database/sqlite_database.dart';
import '../domain/inventory_item.dart';

class InventoryLocalDataSource {
  Future<List<InventoryItem>> search(InventoryFilters filters) async {
    final db = await SQLiteDatabase.database;
    final clauses = <String>[];
    final args = <Object?>[];
    final query = filters.query.trim().toUpperCase();
    if (query.isNotEmpty) {
      clauses.add('(UPPER(referencia) LIKE ? OR UPPER(descripcion) LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }
    if (filters.companyId.isNotEmpty) {
      clauses.add('id_empresa = ?');
      args.add(filters.companyId);
    }
    if (filters.warehouse.isNotEmpty) {
      clauses.add('UPPER(bodega) LIKE ?');
      args.add('${filters.warehouse.toUpperCase()}%');
    }
    if (filters.city.isNotEmpty) {
      clauses.add('UPPER(ciudad_normalizada) = ?');
      args.add(filters.city.toUpperCase());
    }
    if (filters.operationCenter.isNotEmpty) {
      clauses.add('centro_operacion = ?');
      args.add(filters.operationCenter);
    }
    if (filters.onlyAvailable) clauses.add('disponible > 0');

    final rows = await db.query(
      'prioritized_inventory',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'prioridad_marca ASC, disponible DESC, referencia ASC',
      limit: filters.limit,
    );
    return rows.map(InventoryItem.fromDatabase).toList(growable: false);
  }

  Future<void> replace(List<InventoryItem> items, DateTime syncedAt) async {
    if (items.isEmpty) return;
    final db = await SQLiteDatabase.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final item in items) {
        batch.insert(
          'prioritized_inventory',
          item.toDatabase(syncedAt),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
