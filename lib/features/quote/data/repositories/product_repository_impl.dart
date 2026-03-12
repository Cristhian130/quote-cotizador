import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/delivery_rule.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/hive_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/sqlite_data_source.dart';

class ProductRepositoryImpl implements IProductRepository {
  final RemoteDataSource remoteDataSource;
  final SqliteDataSource sqliteDataSource;
  final HiveDataSource hiveDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.sqliteDataSource,
    required this.hiveDataSource,
  });

  @override
  Future<Either<Failure, List<Product>>> searchProducts({
    String? referencia,
    String? descripcion,
    String? bodega,
  }) async {
    try {
      // 1. Verificar si detona Sync en Background (Offline-First Pro)
      _triggerBackgroundSyncIfNeeded();

      // 2. Intentar leer de Hive (Memoria ultra rápida)
      final cached = await hiveDataSource.getCachedSearch(
        referencia: referencia,
        descripcion: descripcion,
        bodega: bodega,
      );

      if (cached != null) {
        return Right(cached);
      }

      // 3. Si no está en Hive, leer de SQLite (Robustez y Filtrado)
      final localData = await sqliteDataSource.searchProducts(
        referencia: referencia,
        descripcion: descripcion,
        bodega: bodega,
      );

      // 4. Actualizar Hive con el resultado para la próxima vez
      await hiveDataSource.cacheSearch(
        referencia: referencia,
        descripcion: descripcion,
        bodega: bodega,
        products: localData,
      );

      return Right(localData);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncProducts({
    void Function(String message)? onProgress,
  }) async {
    try {
      print(
        '🚀 [SYNC] Iniciando descarga de inventario y reglas de entrega...',
      );
      onProgress?.call('Conectando con el servidor para descargas...');

      // 1. Descargar Data pesada de NestJS (Productos y Tarifas en Paralelo)
      final results = await Future.wait([
        remoteDataSource.fetchAllProducts(),
        remoteDataSource.fetchDeliveryRules(),
      ]);

      final apiProducts = results[0] as List<Product>;
      final apiDeliveryRules = results[1] as List<DeliveryRule>;

      print('✅ [SYNC] Descargados ${apiProducts.length} productos del API.');
      print(
        '✅ [SYNC] Descargadas ${apiDeliveryRules.length} reglas de entrega del API.',
      );
      onProgress?.call(
        'Descarga completada: ${apiProducts.length} productos recibidos.\\nPreparando base de datos local...',
      );

      // 2. Volcado a SQLite con persistencia sólida (Ejecutado secuencialmente para evitar el Database Lock)
      print('💾 [SYNC] Guardando en SQLite...');
      onProgress?.call(
        'Guardando productos en la base de datos (paso 1 de 2)...',
      );
      await sqliteDataSource.bulkInsert(apiProducts);
      onProgress?.call('Guardando reglas de entrega (paso 2 de 2)...');
      await sqliteDataSource.bulkInsertDeliveryRules(apiDeliveryRules);

      final countAfter = await sqliteDataSource.getProductsCount();
      print('💾 [SYNC] SQLite ahora tiene $countAfter productos.');
      onProgress?.call(
        'Base de datos SQLite actualizada correctamente con $countAfter productos.',
      );

      // 3. Limpiar Caché de Hive, la data ha cambiado
      print('🗑️  [SYNC] Limpiando caché de Hive...');
      onProgress?.call('Limpiando memoria caché antigua...');
      await hiveDataSource.clearCache();

      // 4. Actualizar tiempo de última sincronización
      await hiveDataSource.updateLastSyncTime();
      print('🎉 [SYNC] ¡Sincronización completada exitosamente!');
      onProgress?.call('¡Sincronización finalizada con éxito!');

      return const Right(null);
    } catch (e, stack) {
      print("==== SYNC PRODUCTS CRASH ====");
      print(e);
      print(stack);
      return Left(ServerFailure(e.toString()));
    }
  }

  void _triggerBackgroundSyncIfNeeded() async {
    final lastSync = hiveDataSource.getLastSyncTime();
    final count = await sqliteDataSource.getProductsCount();

    // Si no hay fecha de sync, base de datos está vacía, o pasaron 4 horas.
    if (lastSync == null ||
        count == 0 ||
        DateTime.now().difference(lastSync).inHours >= 4) {
      // Ejecutar en background (Fire and Forget)
      syncProducts().then((result) {
        result.fold(
          (failure) => print("Background Sync falló: $failure"),
          (_) => print("Background Sync exitoso, 850k refs en SQLite."),
        );
      });
    }
  }
}
