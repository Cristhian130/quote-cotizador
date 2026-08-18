import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../insights/domain/stock_insight.dart';
import '../domain/alert_rules.dart';

class RulesRemoteDataSource {
  final Dio _dio;

  RulesRemoteDataSource(this._dio);

  Future<AlertRules> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/api/cotizacion/reglas-alertas',
    );
    final payload = response.data ?? const <String, dynamic>{};
    return AlertRules.fromJson(
      payload['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  Future<InsightPage> evaluate(RuleEvaluationFilters filters) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/api/cotizacion/reglas-alertas/evaluar',
      data: {
        if (filters.companyId.isNotEmpty) 'idEmpresa': filters.companyId,
        if (filters.city.isNotEmpty) 'ciudad': filters.city,
        'pageSize': filters.pageSize,
        'stockMin': filters.minimumStock,
        'diasSinVentaMin': filters.minimumDaysWithoutSale,
      },
    );
    final payload = response.data ?? const <String, dynamic>{};
    final rows = payload['data'] as List<dynamic>? ?? const [];
    return InsightPage(
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(StockInsight.fromJson)
          .toList(growable: false),
      runId: '${payload['runId'] ?? ''}',
      nextCursor: _intOrNull(payload['nextCursor']),
      total: _intOrNull(payload['total']),
    );
  }
}

int? _intOrNull(Object? value) {
  if (value == null) return null;
  return value is num ? value.toInt() : int.tryParse('$value');
}
