import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class SQLiteDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    try {
      _database = await _initDB('quote_app.db');
    } catch (_) {
      _database = null;
      rethrow;
    }
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      singleInstance: true,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('DROP TABLE IF EXISTS delivery_rules');
          await _createDB(db, newVersion);
          return;
        }
        if (oldVersion < 5) {
          await _createStockIntelligenceTables(db);
        }
        if (oldVersion < 6) {
          await _createManagedBusinessRulesTable(db);
        }
      },
    );
  }

  static Future _createDB(Database db, int version) async {
    const productTable = '''
    CREATE TABLE products (
      referencia TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      bodega TEXT NOT NULL,
      existencia INTEGER NOT NULL,
      disponible INTEGER NOT NULL,
      ubicacion TEXT,
      precioParti REAL NOT NULL,
      precioProfe REAL NOT NULL,
      iva REAL NOT NULL,
      fechaActualizacion TEXT NOT NULL,
      PRIMARY KEY (referencia, bodega)
    )
    ''';
    await db.execute(productTable);

    const deliveryTable = '''
    CREATE TABLE delivery_rules (
      oi INTEGER PRIMARY KEY,
      cia TEXT NOT NULL,
      co TEXT NOT NULL,
      moneda TEXT NOT NULL,
      tipoV TEXT NOT NULL,
      planCliente TEXT NOT NULL,
      criterioCli TEXT NOT NULL,
      bodegaId TEXT NOT NULL,
      paisOrigen TEXT NOT NULL,
      dptoOrigen TEXT NOT NULL,
      ciudadOrigen TEXT NOT NULL,
      barrioOrigen TEXT NOT NULL,
      paisDestino TEXT NOT NULL,
      dptoDestino TEXT NOT NULL,
      ciudadDestino TEXT NOT NULL,
      barrioDestino TEXT NOT NULL,
      tarifa REAL NOT NULL,
      diasEntrega INTEGER NOT NULL,
      fechaActualizacion TEXT NOT NULL
    )
    ''';
    await db.execute(deliveryTable);

    // Crear índice para búsqueda rápida
    await db.execute(
      'CREATE INDEX idx_products_search ON products(referencia, descripcion, bodega)',
    );

    // Índices para Tarifas Domicilio
    await db.execute(
      'CREATE INDEX idx_delivery_rules_search ON delivery_rules(bodegaId, ciudadDestino, barrioDestino)',
    );

    await _createStockIntelligenceTables(db);
  }

  static Future<void> _createStockIntelligenceTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prioritized_inventory (
        local_key TEXT PRIMARY KEY,
        referencia TEXT NOT NULL,
        descripcion TEXT,
        bodega TEXT NOT NULL,
        id_empresa TEXT,
        centro_operacion TEXT,
        ciudad_normalizada TEXT,
        existencia REAL NOT NULL DEFAULT 0,
        disponible REAL NOT NULL DEFAULT 0,
        ubicacion TEXT,
        precio_parti REAL NOT NULL DEFAULT 0,
        precio_profe REAL NOT NULL DEFAULT 0,
        iva REAL NOT NULL DEFAULT 0,
        proveedor_marca_codigo TEXT,
        proveedor_marca_descripcion TEXT,
        prioridad_marca INTEGER NOT NULL DEFAULT 99,
        subgrupo_codigo TEXT,
        aplica_descuento INTEGER NOT NULL DEFAULT 1,
        bodega_ambigua INTEGER NOT NULL DEFAULT 0,
        fecha_actualizacion TEXT,
        synced_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_prioritized_inventory_ref ON prioritized_inventory(referencia)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_prioritized_inventory_desc ON prioritized_inventory(descripcion)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_prioritized_inventory_filters ON prioritized_inventory(id_empresa, ciudad_normalizada, bodega, disponible)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_rotation_snapshot (
        snapshot_id INTEGER PRIMARY KEY,
        run_id TEXT NOT NULL,
        fecha_snapshot TEXT,
        id_empresa TEXT,
        bodega TEXT,
        centro_operacion TEXT,
        ciudad_normalizada TEXT,
        referencia TEXT NOT NULL,
        descripcion TEXT,
        prioridad_marca INTEGER NOT NULL DEFAULT 99,
        clasificacion_abc TEXT,
        frecuencia TEXT,
        dias_sin_venta INTEGER NOT NULL DEFAULT 0,
        stock_disponible REAL NOT NULL DEFAULT 0,
        stock_existente REAL NOT NULL DEFAULT 0,
        ventas_ultimos_90_dias REAL NOT NULL DEFAULT 0,
        ventas_ultimos_180_dias REAL NOT NULL DEFAULT 0,
        rotacion REAL NOT NULL DEFAULT 0,
        stock_alto_baja_rotacion INTEGER NOT NULL DEFAULT 0,
        aplica_descuento INTEGER NOT NULL DEFAULT 1,
        sugerencia_comercial TEXT,
        synced_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rotation_run_cursor ON product_rotation_snapshot(run_id, snapshot_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rotation_ref ON product_rotation_snapshot(referencia)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rotation_filters ON product_rotation_snapshot(id_empresa, ciudad_normalizada, bodega, clasificacion_abc, frecuencia)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rotation_alerts ON product_rotation_snapshot(stock_alto_baja_rotacion, dias_sin_venta, stock_existente)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_alert_rules (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        inventario_dias_min INTEGER NOT NULL,
        stock_alto_min REAL NOT NULL,
        ventas_ultimos_180_max REAL NOT NULL,
        clasificaciones TEXT NOT NULL,
        sugerencias TEXT NOT NULL,
        subgrupos_sin_descuento TEXT NOT NULL,
        default_page_size INTEGER NOT NULL,
        max_page_size INTEGER NOT NULL,
        recommended_mode TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

    await _createManagedBusinessRulesTable(db);
  }

  static Future<void> _createManagedBusinessRulesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_business_rules (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo_condicion TEXT NOT NULL,
        umbral REAL NOT NULL,
        tipo_accion TEXT NOT NULL,
        valor_accion REAL NOT NULL DEFAULT 0,
        activa INTEGER NOT NULL DEFAULT 1,
        es_predeterminada INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    final defaults = <Map<String, Object?>>[
      {
        'id': 'default-inventory-age',
        'nombre': 'Inventario estancado > 90 días',
        'tipo_condicion': 'inventoryAge',
        'umbral': 90,
        'tipo_accion': 'applyDiscount',
        'valor_accion': 15,
        'activa': 1,
        'es_predeterminada': 1,
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      },
      {
        'id': 'default-high-stock-low-rotation',
        'nombre': 'Stock alto con baja rotación (ZZ)',
        'tipo_condicion': 'highStockLowRotation',
        'umbral': 50,
        'tipo_accion': 'transferProduct',
        'valor_accion': 20,
        'activa': 1,
        'es_predeterminada': 1,
        'created_at': '2026-01-01T00:00:00.001',
        'updated_at': '2026-01-01T00:00:00.001',
      },
      {
        'id': 'default-city-inventory-difference',
        'nombre': 'Diferencia de inventario entre ciudades',
        'tipo_condicion': 'cityInventoryDifference',
        'umbral': 30,
        'tipo_accion': 'transferProduct',
        'valor_accion': 10,
        'activa': 0,
        'es_predeterminada': 1,
        'created_at': '2026-01-01T00:00:00.002',
        'updated_at': '2026-01-01T00:00:00.002',
      },
    ];
    for (final rule in defaults) {
      await db.insert(
        'stock_business_rules',
        rule,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
