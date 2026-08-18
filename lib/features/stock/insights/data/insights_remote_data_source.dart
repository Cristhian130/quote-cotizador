import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../domain/stock_insight.dart';

class InsightsRemoteDataSource {
  final Dio _dio;

  InsightsRemoteDataSource(this._dio);

  Future<InsightPage> fetch(InsightFilters filters) async {
    final path = filters.onlyAlerts
        ? '/api/cotizacion/alertas-productos'
        : '/api/cotizacion/productos-rotacion';
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}$path',
      queryParameters: {
        'cursor': filters.cursor ?? 0,
        'pageSize': filters.pageSize,
        if (filters.query.isNotEmpty)
          filters.searchByDescription ? 'descripcion' : 'referencia':
              filters.query.trim(),
        if (filters.companyId.isNotEmpty) 'idEmpresa': filters.companyId,
        if (filters.warehouse.isNotEmpty) 'bodega': filters.warehouse,
        if (filters.city.isNotEmpty) 'ciudad': filters.city,
        if (filters.classification.isNotEmpty)
          'clasificacion': filters.classification,
        if (filters.frequency.isNotEmpty) 'frecuencia': filters.frequency,
        if (filters.suggestion.isNotEmpty) 'sugerencia': filters.suggestion,
        if (filters.minimumStock != null) 'stockMin': filters.minimumStock,
        if (filters.minimumDaysWithoutSale != null)
          'diasSinVentaMin': filters.minimumDaysWithoutSale,
        'soloAlertas': filters.onlyAlerts,
        'includeTotal': filters.cursor == null,
      },
    );
    return pageFromPayload(response.data ?? const <String, dynamic>{});
  }

  InsightPage pageFromPayload(Map<String, dynamic> payload) {
    final rows = payload['data'] as List<dynamic>? ?? const [];
    return InsightPage(
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(StockInsight.fromJson)
          .toList(growable: false),
      runId: '${payload['runId'] ?? ''}',
      nextCursor: _nullableInt(payload['nextCursor']),
      total: _nullableInt(payload['total']),
    );
  }
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  return value is num ? value.toInt() : int.tryParse('$value');
}
