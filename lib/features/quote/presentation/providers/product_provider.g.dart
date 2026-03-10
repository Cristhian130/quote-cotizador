// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteDataSource)
final remoteDataSourceProvider = RemoteDataSourceProvider._();

final class RemoteDataSourceProvider
    extends
        $FunctionalProvider<
          RemoteDataSource,
          RemoteDataSource,
          RemoteDataSource
        >
    with $Provider<RemoteDataSource> {
  RemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<RemoteDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoteDataSource create(Ref ref) {
    return remoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteDataSource>(value),
    );
  }
}

String _$remoteDataSourceHash() => r'4e0494922526ceeaeecacff801002549678dc6b5';

@ProviderFor(sqliteDataSource)
final sqliteDataSourceProvider = SqliteDataSourceProvider._();

final class SqliteDataSourceProvider
    extends
        $FunctionalProvider<
          SqliteDataSource,
          SqliteDataSource,
          SqliteDataSource
        >
    with $Provider<SqliteDataSource> {
  SqliteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sqliteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sqliteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SqliteDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SqliteDataSource create(Ref ref) {
    return sqliteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SqliteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SqliteDataSource>(value),
    );
  }
}

String _$sqliteDataSourceHash() => r'cd4e5a28963277e4278608fbb85f1e648e7dbb65';

@ProviderFor(hiveDataSource)
final hiveDataSourceProvider = HiveDataSourceProvider._();

final class HiveDataSourceProvider
    extends $FunctionalProvider<HiveDataSource, HiveDataSource, HiveDataSource>
    with $Provider<HiveDataSource> {
  HiveDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiveDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiveDataSourceHash();

  @$internal
  @override
  $ProviderElement<HiveDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HiveDataSource create(Ref ref) {
    return hiveDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HiveDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HiveDataSource>(value),
    );
  }
}

String _$hiveDataSourceHash() => r'3363fc21fb0b5b5884621bfec1baac3e6b4c08d4';

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepositoryImpl,
          ProductRepositoryImpl,
          ProductRepositoryImpl
        >
    with $Provider<ProductRepositoryImpl> {
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepositoryImpl create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepositoryImpl>(value),
    );
  }
}

String _$productRepositoryHash() => r'36c438820162630354908d9e4b21d85eb56359fd';

@ProviderFor(ProductSearch)
final productSearchProvider = ProductSearchProvider._();

final class ProductSearchProvider
    extends $AsyncNotifierProvider<ProductSearch, List<Product>> {
  ProductSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSearchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSearchHash();

  @$internal
  @override
  ProductSearch create() => ProductSearch();
}

String _$productSearchHash() => r'236cc041252fe6ff5cdaeba576ca60f39511a5b6';

abstract class _$ProductSearch extends $AsyncNotifier<List<Product>> {
  FutureOr<List<Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Product>>, List<Product>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Product>>, List<Product>>,
              AsyncValue<List<Product>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
