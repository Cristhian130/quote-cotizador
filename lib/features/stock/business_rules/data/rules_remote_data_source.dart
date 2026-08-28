import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../insights/domain/stock_insight.dart';
import '../domain/business_rule.dart';
import '../domain/rule_evaluation_filters.dart';

class RulesRemoteDataSource {
  final Dio _dio;

  RulesRemoteDataSource(this._dio);

  String get _rulesUrl =>
      '${AppConfig.baseUrl}/api/cotizacion/reglas-alertas';

  Future<List<BusinessRule>> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _rulesUrl,
    );
    final payload = response.data ?? const <String, dynamic>{};
    return _ruleRows(payload)
        .map(BusinessRule.fromJson)
        .toList(growable: false);
  }

  Future<BusinessRule> create(BusinessRule rule) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _rulesUrl,
      data: rule.toApiJson(),
    );
    return _ruleFromResponse(response.data, fallback: rule);
  }

  Future<BusinessRule> update(BusinessRule rule) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$_rulesUrl/${Uri.encodeComponent(rule.id)}',
      data: rule.toApiJson(),
    );
    return _ruleFromResponse(response.data, fallback: rule);
  }

  Future<BusinessRule> toggle(BusinessRule rule) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$_rulesUrl/${Uri.encodeComponent(rule.id)}/toggle',
    );
    return _ruleFromResponse(
      response.data,
      fallback: rule.copyWith(
        enabled: !rule.enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> delete(BusinessRule rule) async {
    await _dio.delete<void>('$_rulesUrl/${Uri.encodeComponent(rule.id)}');
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

Iterable<Map<String, dynamic>> _ruleRows(Map<String, dynamic> payload) {
  final data = payload['data'] ?? payload['rules'] ?? payload['reglas'];
  if (data is List) return data.whereType<Map<String, dynamic>>();
  if (data is Map<String, dynamic>) {
    final rows = data['rules'] ?? data['reglas'];
    if (rows is List) return rows.whereType<Map<String, dynamic>>();
  }
  throw const FormatException('La API no devolvió una lista de reglas.');
}

BusinessRule _ruleFromResponse(
  Map<String, dynamic>? payload, {
  required BusinessRule fallback,
}) {
  final data = payload?['data'] ?? payload?['rule'] ?? payload?['regla'];
  Map<String, dynamic>? responseRule;
  if (data is Map<String, dynamic>) {
    final nested = data['rule'] ?? data['regla'];
    responseRule = nested is Map<String, dynamic> ? nested : data;
  } else if (payload != null &&
      (payload.containsKey('id') || payload.containsKey('nombre'))) {
    responseRule = payload;
  }
  if (responseRule == null || responseRule.isEmpty) return fallback;
  return BusinessRule.fromJson({
    'id': fallback.id,
    'nombre': fallback.name,
    'tipo': fallback.condition.apiValue,
    'umbral': fallback.threshold,
    'accion': fallback.action.apiValue,
    'valorAccion': fallback.actionValue,
    'activa': fallback.enabled,
    'preset': fallback.isDefault,
    'createdAt': fallback.createdAt.toIso8601String(),
    'updatedAt': fallback.updatedAt.toIso8601String(),
    ...responseRule,
  });
}

int? _intOrNull(Object? value) {
  if (value == null) return null;
  return value is num ? value.toInt() : int.tryParse('$value');
}
