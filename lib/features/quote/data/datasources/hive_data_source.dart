import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database.dart';
import '../../domain/entities/product.dart';

class HiveDataSource {
  Box get _productBox => HiveDatabase.productBox;
  Box get _syncBox => HiveDatabase.syncBox;

  String _generateCacheKey({
    String? referencia,
    String? descripcion,
    String? bodega,
  }) {
    return '${referencia ?? ''}_${descripcion ?? ''}_${bodega ?? ''}';
  }

  Future<List<Product>?> getCachedSearch({
    String? referencia,
    String? descripcion,
    String? bodega,
  }) async {
    final key = _generateCacheKey(
      referencia: referencia,
      descripcion: descripcion,
      bodega: bodega,
    );
    final cachedData = _productBox.get(key);

    if (cachedData != null) {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> cacheSearch({
    String? referencia,
    String? descripcion,
    String? bodega,
    required List<Product> products,
  }) async {
    final key = _generateCacheKey(
      referencia: referencia,
      descripcion: descripcion,
      bodega: bodega,
    );

    final jsonList = products.map((p) => p.toJson()).toList();
    await _productBox.put(key, jsonEncode(jsonList));
  }

  Future<void> clearCache() async {
    await _productBox.clear();
  }

  DateTime? getLastSyncTime() {
    final timeStr = _syncBox.get('last_sync');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  Future<void> updateLastSyncTime() async {
    await _syncBox.put('last_sync', DateTime.now().toIso8601String());
  }
}
