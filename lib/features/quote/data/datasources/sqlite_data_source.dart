import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqlite_database.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/delivery_rule.dart';

class SqliteDataSource {
  Future<Database> get _db => SQLiteDatabase.database;

  Future<void> bulkInsert(List<Product> products) async {
    final db = await _db;

    // Ejecutar en una sola transacción atómica:
    // 1) Borrar todo lo viejo (productos vendidos, cambios de precio, etc.)
    // 2) Insertar los datos frescos del API
    await db.transaction((txn) async {
      await txn.delete('products'); // TRUNCATE lógico
      print(
        '🗑️ [DB] Tabla products limpiada. Insertando ${products.length} filas...',
      );

      final batch = txn.batch();
      for (final product in products) {
        batch.insert(
          'products',
          product.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Product>> searchProducts({
    String? referencia,
    String? descripcion,
    String? bodega,
  }) async {
    final db = await _db;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (referencia != null && referencia.isNotEmpty) {
      whereClause += ' AND referencia LIKE ?';
      whereArgs.add('%$referencia%');
    }
    if (descripcion != null && descripcion.isNotEmpty) {
      whereClause += ' AND descripcion LIKE ?';
      whereArgs.add('%$descripcion%');
    }
    if (bodega != null && bodega.isNotEmpty) {
      whereClause += ' AND bodega = ?';
      whereArgs.add(bodega);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 100, // Máximo de elementos a renderizar de un solo golpe en UI
    );

    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<int> getProductsCount() async {
    final db = await _db;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
  }

  // --- DELIVERY RULES OFFLINE ---

  Future<void> bulkInsertDeliveryRules(List<DeliveryRule> rules) async {
    if (rules.isEmpty)
      return; // Si el endpoint no disponible, no tocamos la tabla
    final db = await _db;

    try {
      await db.transaction((txn) async {
        await txn.delete('delivery_rules');
        print(
          '🗑️ [DB] Tabla delivery_rules limpiada. Insertando ${rules.length} filas...',
        );

        final batch = txn.batch();
        for (final rule in rules) {
          batch.insert('delivery_rules', rule.toJson());
        }
        await batch.commit(noResult: true);
      });
    } catch (e) {
      print("=== DB BULK INSERT RULES ERROR ===");
      print(e);
    }
  }

  Future<List<String>> getUniqueCitiesForBodega(String bodegaId) async {
    final db = await _db;
    if (bodegaId.isEmpty) {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT ciudadDestino FROM delivery_rules ORDER BY ciudadDestino ASC',
      );
      return maps.map((e) => e['ciudadDestino'] as String).toList();
    } else {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT ciudadDestino FROM delivery_rules WHERE bodegaId = ? ORDER BY ciudadDestino ASC',
        [bodegaId],
      );
      return maps.map((e) => e['ciudadDestino'] as String).toList();
    }
  }

  Future<List<String>> getUniqueBarrios(
    String bodegaId,
    String ciudadDestino,
  ) async {
    final db = await _db;
    if (bodegaId.isEmpty) {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT barrioDestino FROM delivery_rules WHERE ciudadDestino = ? ORDER BY barrioDestino ASC',
        [ciudadDestino],
      );
      return maps.map((e) => e['barrioDestino'] as String).toList();
    } else {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT barrioDestino FROM delivery_rules WHERE bodegaId = ? AND ciudadDestino = ? ORDER BY barrioDestino ASC',
        [bodegaId, ciudadDestino],
      );
      return maps.map((e) => e['barrioDestino'] as String).toList();
    }
  }

  Future<DeliveryRule?> getDeliveryRule({
    required String bodegaId,
    required String ciudadDestino,
    required String barrioDestino,
    required String tipoV,
  }) async {
    final db = await _db;

    final whereClause = bodegaId.isEmpty
        ? 'ciudadDestino = ? AND barrioDestino = ? AND tipoV = ?'
        : 'bodegaId = ? AND ciudadDestino = ? AND barrioDestino = ? AND tipoV = ?';

    final whereArgs = bodegaId.isEmpty
        ? [ciudadDestino, barrioDestino, tipoV]
        : [bodegaId, ciudadDestino, barrioDestino, tipoV];

    final List<Map<String, dynamic>> maps = await db.query(
      'delivery_rules',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DeliveryRule.fromJson(maps.first);
    }
    return null;
  }

  Future<List<String>> getUniqueVehiculos(
    String bodegaId,
    String ciudadDestino,
    String barrioDestino,
  ) async {
    final db = await _db;
    if (bodegaId.isEmpty) {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT tipoV FROM delivery_rules WHERE ciudadDestino = ? AND barrioDestino = ? ORDER BY tipoV ASC',
        [ciudadDestino, barrioDestino],
      );
      return maps.map((e) => e['tipoV'] as String).toList();
    } else {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT tipoV FROM delivery_rules WHERE bodegaId = ? AND ciudadDestino = ? AND barrioDestino = ? ORDER BY tipoV ASC',
        [bodegaId, ciudadDestino, barrioDestino],
      );
      return maps.map((e) => e['tipoV'] as String).toList();
    }
  }
}
