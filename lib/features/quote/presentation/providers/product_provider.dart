import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/sqlite_data_source.dart';
import '../../data/datasources/hive_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'product_provider.g.dart';

@riverpod
RemoteDataSource remoteDataSource(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 15),
      // SQL Server SP takes 11 minutes
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        // Bypasses ngrok's browser interstitial warning page.
        // Ignored by localhost and other backends.
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );
  return RemoteDataSource(dio);
}

@riverpod
SqliteDataSource sqliteDataSource(Ref ref) {
  return SqliteDataSource();
}

@riverpod
HiveDataSource hiveDataSource(Ref ref) {
  return HiveDataSource();
}

@riverpod
ProductRepositoryImpl productRepository(Ref ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    sqliteDataSource: ref.watch(sqliteDataSourceProvider),
    hiveDataSource: ref.watch(hiveDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
class ProductSearch extends _$ProductSearch {
  @override
  FutureOr<List<Product>> build() {
    return [];
  }

  Future<void> search({
    String? referencia,
    String? descripcion,
    String? bodega,
  }) async {
    if ((descripcion == null || descripcion.trim().length < 3) &&
        (referencia == null || referencia.trim().isEmpty) &&
        (bodega == null || bodega.trim().isEmpty)) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.searchProducts(
      referencia: referencia?.trim(),
      descripcion: descripcion?.trim(),
      bodega: bodega?.trim(),
    );

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (products) => state = AsyncData(products),
    );
  }
}
