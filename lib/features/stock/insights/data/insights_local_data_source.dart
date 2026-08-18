import 'package:sqflite/sqflite.dart';

import '../../../../core/database/sqlite_database.dart';
import '../domain/stock_insight.dart';

class InsightsLocalDataSource {
  Future<InsightPage> search(InsightFilters filters) async {
    final db = await SQLiteDatabase.database;
    final clauses = <String>[];
    final args = <Object?>[];
    final query = filters.query.trim().toUpperCase();
    if (query.isNotEmpty) {
      clauses.add('(UPPER(referencia) LIKE ? OR UPPER(descripcion) LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }
    void exact(String column, String value) {
      if (value.isNotEmpty) {
        clauses.add('$column = ?');
        args.add(value.toUpperCase());
      }
    }

    exact('id_empresa', filters.companyId);
    exact('UPPER(bodega)', filters.warehouse);
    exact('UPPER(ciudad_normalizada)', filters.city);
    exact('UPPER(clasificacion_abc)', filters.classification);
    exact('UPPER(frecuencia)', filters.frequency);
    if (filters.suggestion.isNotEmpty) {
      clauses.add('LOWER(sugerencia_comercial) = ?');
      args.add(filters.suggestion.toLowerCase());
    }
    if (filters.minimumStock != null) {
      clauses.add('stock_existente >= ?');
      args.add(filters.minimumStock);
    }
    if (filters.minimumDaysWithoutSale != null) {
      clauses.add('dias_sin_venta >= ?');
      args.add(filters.minimumDaysWithoutSale);
    }
    if (filters.onlyAlerts) clauses.add('stock_alto_baja_rotacion = 1');

    final rows = await db.query(
      'product_rotation_snapshot',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args,
      orderBy:
          'stock_alto_baja_rotacion DESC, prioridad_marca ASC, dias_sin_venta DESC',
      limit: filters.pageSize,
    );
    final items = rows.map(StockInsight.fromDatabase).toList(growable: false);
    return InsightPage(
      items: items,
      runId: items.isEmpty ? '' : items.first.runId,
    );
  }

  Future<void> replacePage(
    InsightPage page,
    DateTime syncedAt, {
    required bool clearPreviousRun,
  }) async {
    final db = await SQLiteDatabase.database;
    await db.transaction((txn) async {
      if (clearPreviousRun && page.runId.isNotEmpty) {
        await txn.delete(
          'product_rotation_snapshot',
          where: 'run_id <> ?',
          whereArgs: [page.runId],
        );
      }
      final batch = txn.batch();
      for (final item in page.items) {
        batch.insert(
          'product_rotation_snapshot',
          item.toDatabase(syncedAt),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
