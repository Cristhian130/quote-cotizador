import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../domain/inventory_item.dart';

class InventoryRemoteDataSource {
  final Dio _dio;

  InventoryRemoteDataSource(this._dio);

  Future<List<InventoryItem>> fetch(InventoryFilters filters) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/api/cotizacion/inventario/priorizado',
      queryParameters: {
        if (filters.query.trim().isNotEmpty)
          filters.searchByDescription ? 'descripcion' : 'referencia':
              filters.query.trim(),
        if (filters.companyId.isNotEmpty) 'idEmpresa': filters.companyId,
        if (filters.warehouse.isNotEmpty) 'bodega': filters.warehouse,
        if (filters.city.isNotEmpty) 'ciudadOrigen': filters.city,
        if (filters.operationCenter.isNotEmpty)
          'centroOperacion': filters.operationCenter,
        'soloDisponibles': filters.onlyAvailable,
        'limit': filters.limit,
      },
    );
    final payload = response.data ?? const <String, dynamic>{};
    final rows = payload['data'] as List<dynamic>? ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(InventoryItem.fromJson)
        .toList(growable: false);
  }
}
