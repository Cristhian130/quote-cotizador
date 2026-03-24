import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SQLiteDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quote_app.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    late String dbPath;

    // On Windows/Linux/macOS (desktop), getDatabasesPath() points to the
    // installation folder which is read-only once the app is installed.
    // Use getApplicationSupportDirectory() instead – this always resolves to a
    // user-writable location (e.g. %APPDATA%\quote on Windows).
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appSupportDir = await getApplicationSupportDirectory();
      dbPath = appSupportDir.path;
    } else {
      dbPath = await getDatabasesPath();
    }

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Simplest migration: drop and recreate
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('DROP TABLE IF EXISTS delivery_rules');
          await _createDB(db, newVersion);
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
  }
}
